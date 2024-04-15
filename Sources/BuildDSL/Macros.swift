//
//  Macros.swift
//
//  Created by Ahmed Ali (github.com/Ahmed-Ali) on 22/04/2024.
//

/**
 @Builder macro will generate boilerplate to take advantage of several language features to enable a simple, intuitive, composite and safe instance creation approach.

 ## Examples:
  ```
  @Builder
  struct UserAgent {
      let client: String
      let os: String

      @Ignore
      var fullHeader: String = "....."
  }

  @Builder
  struct NetworkConfig {
      // You can use @Default even
      // with `let` properties
      @Default(Region.US)
      let region: Region
      let useragent: UserAgent
  }

  enum Region {
      case US, EU, ASIA
  }

  // This will generate a failable initializer and the static `build` method
  // which returns a Result<Type, Error>
  // both the initializer and the `build` method use a specialized
  // result builder for better readability and ensuring
  // the creation closure is not usable for anything other than
  // building the object
  let testConfig = NetworkConfig.build { $0
      .region(.ASIA) // overriding the default value
      .useragentBuilder { $0 // nested result builder
          .client("Desktop")
          .os("MacOS")
          // the fullHeader property is ignored, and won't have a setter in the builder
      }
      // You can also use normal setter for nested structs. Both options available
      .useragent(UserAgent(client: "Desktop", os: "MacOS"))
  }

  // The above code returns a Result, you can do few things with that
  do {
      let productionConfig = try NetworkConfig.build { $0
          // You can also use normal setter for nested structs. Both options available
          .useragent(UserAgent(client: "Desktop", os: "MacOS"))
      }.get()
  } catch {
      // handle the error
  }

  // alternatively
  switch testConfig {
      case let .success(conf):
          // success
          print(conf)
      case let .failure(e):
          print(e)
  }

  // you can also handle it gracefully
  // the initializer will return NetworkConfig?
  let conf = NetworkConfig { $0
      .useragentBuilder { $0
          // ....
      }
  }

  // also this works the same
  let network = try? NetworkConfig.build { $0
      ///
  }.get() // `get` throws

  There is more
  func createNetworkClient(@NetworkConfig.ResultBuilder configResultBuilder: NetworkConfig.BuilderClosure) {
      let config = try? NetworkConfig.build(configResultBuilder).get()
  }

  // Now your own users can benefit from the generated resuld builder
  createNetworkClient { $0
      .useragent(UserAgent(client: "Client", os: "OS"))
  }
  */
@attached(extension, conformances: BuildableAPI, names: arbitrary)
public macro Builder() =
    #externalMacro(
        module: "BuildDSLMacros",
        type: "BuilderMacro"
    )

/**
  Just like `var property: Type = DefaultValue` in Swift
  Except you can use it with `let property: Type` as well
  ```
 @Builder
 struct MyStruct {
     @Default("Default Value")
     let property: String
 }
 ```
  */
@attached(peer)
public macro Default(_ value: Any) =
    #externalMacro(
        module: "BuildDSLMacros",
        type: "MarkerMacro"
    )

/**
   Use the @Ignore macro to make sure it won't have a setter in the generated builder
 ```
 @Builder
 struct MyStruct {
     // will have a setter in the generated builder as expected
     let property1: String
     let property2: String

     // Won't have a setter in the generated builder
     @Ignore
     var ignoredProperty: String = "Default Value"
 }
 ```

 **Note:**
 When using @Ignore with a property, it has to be initialized somewhere else.
 Any of the following will do:
 1. Set a default value at declaration: i.e `var ignoredProperty: String = "Default Value"`
 2. Add an initalizer that's exacly like the memberwise initializer:
 ```
 extension MyStruct {
     init(property1: String, property2: String) {
         self.property1 = property1
         self.property2 = property2
         self.ignoredProperty = "Default Value"
     }
 }
 ```

 The order and names of the parameters has to match the memberwise initializer
  */
@attached(peer)
public macro Ignore() =
    #externalMacro(
        module: "BuildDSLMacros",
        type: "MarkerMacro"
    )

/**
 While the @Builder macro will be able to do the right thing for
 closure properties, it can't do much if the type doesn't look like a closure
 Few examples:
 ```
 @Builder
 struct MyStruct {
     let callback: () -> ()
 }
 ```
 Works just fine and the setter for the callback will look like the following
 ```
 func callback(_ value: @escaping () -> ()) -> MyStruct.Builder {
     self.callback = value
     return self
 }
 ```
 While the following will fail
 ```
 typealias MyCallBack = () -> ()
 @Builder
 struct MyStruct {
     let callback: MyCallBack
 }

 // It will generate
 func callback(_ value: MyCallBack) -> MyStruct.Builder {
     self.callback = value
     return self
 }
 ```
 The setter API for the callback property will use @escaping closure to make sure it can be
 stored
 While the following example won't compile
 ```
 typealias MyCallBack = () -> ()
 @Builder
 struct MyStruct {
     let callback: MyCallBack
 }
 ```
 The setter API in the above example will be
 ```
 func callback(_ value: MyCallBack) -> MyStruct.Builder {
     self.callback = value
     return self
 }
 ```
 This will cause complier error because
 `Assigning non-escaping parameter 'value' to an @escaping closure`

 For these cases, you can help by using the @Escaping macro explicitly as follows
 ```
 typealias MyCallBack = () -> ()
 @Builder
 struct MyStruct {
     @Escaping
     let callback: MyCallBack
 }
 ```
 Which will generate
 ```
 func callback(_ value: @escaping MyCallBack) -> MyStruct.Builder {
     self.callback = value
     return self
 }
 ```
 */
@attached(peer)
public macro Escaping() =
    #externalMacro(module: "BuildDSLMacros", type: "MarkerMacro")
