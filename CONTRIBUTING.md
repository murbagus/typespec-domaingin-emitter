# Contributing to TypeSpec Go Emitter

Thank you for your interest in contributing to TypeSpec Go Emitter! This document provides guidelines and information for contributors.

## Development Setup

1. **Clone the repository**:

```bash
git clone https://github.com/your-org/typespec-go-emitter.git
cd typespec-go-emitter
```

2. **Install dependencies**:

```bash
npm install
```

3. **Build the project**:

```bash
npm run build
```

4. **Watch for changes during development**:

```bash
npm run watch
```

## Project Structure

```
typespec-go-emitter/
├── src/
│   └── index.ts          # Main emitter implementation
├── dist/                 # Compiled JavaScript output
├── README.md            # Project documentation
├── package.json         # Package configuration
├── tsconfig.json        # TypeScript configuration
└── LICENSE              # MIT License
```

## Development Guidelines

### Code Style

- Use TypeScript for all source code
- Follow existing code style and formatting
- Add JSDoc comments for public APIs
- Use meaningful variable and function names

### Commit Messages

Follow conventional commit format:

- `feat: add new feature`
- `fix: resolve bug`
- `docs: update documentation`
- `refactor: improve code structure`
- `test: add or update tests`

### Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Build and test your changes: `npm run build`
5. Commit your changes with a descriptive message
6. Push to your fork: `git push origin feature/your-feature-name`
7. Open a pull request

## Testing

Currently, the project uses manual testing. To test your changes:

1. Create a sample TypeSpec project
2. Use your modified emitter
3. Verify the generated Go code is correct
4. Test various TypeSpec features (nullable types, validation, etc.)

## Adding New Features

When adding new features:

1. **Update the interface**: Add new options to `GoEmitterOptions` if needed
2. **Update defaults**: Add default values to `defaultOptions`
3. **Implement the feature**: Add the logic in the appropriate methods
4. **Update documentation**: Update README.md with examples
5. **Test thoroughly**: Ensure the feature works with various inputs

## Common Development Tasks

### Adding New Type Mappings

To add support for new TypeSpec types:

1. Update the `typeToGoType` method in `src/index.ts`
2. Add the new type mapping to the documentation
3. Test with sample TypeSpec code

### Adding New Validation Tags

To support new TypeSpec decorators:

1. Update the `buildValidationTagsDetailed` method
2. Add the decorator mapping logic
3. Update the validation tags documentation

### Changing Output Format

To modify the generated Go code format:

1. Update the relevant `emit*` methods
2. Ensure backward compatibility when possible
3. Update examples in documentation

## Release Process

1. Update version in `package.json`
2. Update CHANGELOG.md (if exists)
3. Create a git tag: `git tag v1.x.x`
4. Push tags: `git push --tags`
5. Publish to npm: `npm publish`

## Bug Reports

When reporting bugs, please include:

- TypeSpec version
- Emitter version
- Sample TypeSpec code that reproduces the issue
- Expected vs actual output
- Error messages (if any)

## Feature Requests

For feature requests, please:

- Check if the feature already exists
- Provide a clear use case
- Include sample TypeSpec code showing desired behavior
- Describe the expected Go output

## Questions and Support

- Check the README.md for common usage patterns
- Look through existing issues for similar questions
- Open a new issue with the "question" label

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing! 🎉
