# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Swift Package Index compatibility
- Comprehensive CI/CD pipeline with GitHub Actions
- SwiftLint configuration for code quality
- Code coverage reporting
- API compatibility checking
- Documentation generation
- Support for all Apple platforms including visionOS

### Changed
- Improved test coverage
- Enhanced documentation with inline docs
- Better error handling in test cases

### Fixed
- Test syntax errors with `@Default` macro usage

## [0.1.0] - Initial Release

### Added
- `@Builder` macro for auto-generating builder patterns
- `@Default` macro for setting default values
- `@Ignore` macro for excluding properties from builders  
- `@Escaping` macro for closure parameters
- Type-safe DSL with `@resultBuilder`
- Comprehensive error handling with `BuilderError`
- Support for nested builders
- Failable and non-failable initialization patterns
- Full test suite with macro testing support