# Flutter 3D App - Modular Architecture Documentation

## Overview

This document describes the modular, testable architecture of the Flutter 3D App, including dependency injection, extension points, and testing strategies.

## Architecture Principles

### 1. Clean Architecture
- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: All components can be unit tested independently

### 2. MVVM Pattern
- **Model**: Domain entities and business logic
- **View**: UI components and widgets
- **ViewModel**: Business logic and state management

### 3. Dependency Injection
- **Service Locator**: Centralized service registration and retrieval
- **Interface Segregation**: Services implement specific interfaces
- **Mock Services**: Easy testing with mock implementations

## Project Structure

```
lib/
├── core/
│   ├── di/
│   │   ├── injection_container.dart      # Legacy DI container
│   │   └── service_locator.dart          # New service locator
│   ├── mvvm/
│   │   └── base_view_model.dart          # Base ViewModel class
│   └── errors/
│       ├── exceptions.dart               # Custom exceptions
│       └── failures.dart                 # Custom failures
├── features/
│   └── model_viewer/
│       ├── domain/
│       │   ├── entities/                 # Domain entities
│       │   ├── services/
│       │   │   ├── interfaces/           # Service interfaces
│       │   │   ├── implementations/      # Service implementations
│       │   │   └── extensions/           # Extension registry
│       │   └── repositories/             # Repository interfaces
│       └── presentation/
│           ├── providers/                # Legacy providers
│           ├── viewmodels/               # MVVM ViewModels
│           └── pages/                    # UI pages
└── test/
    ├── features/
    │   └── model_viewer/
    │       ├── domain/
    │       │   └── services/             # Domain service tests
    │       └── presentation/
    │           └── viewmodels/           # ViewModel tests
    ├── core/
    │   └── di/                          # DI tests
    └── test_runner.dart                 # Test utilities
```

## Core Components

### 1. Service Locator

The `ServiceLocator` provides centralized dependency injection:

```dart
// Register services
ServiceLocator.registerService<ProcrustesServiceInterface>(
  () => ProcrustesServiceImpl(),
  asSingleton: true,
);

// Get services
final service = ServiceLocator.get<ProcrustesServiceInterface>();
```

### 2. Base ViewModel

All ViewModels extend `BaseViewModel` for common functionality:

```dart
class ObjectViewModel extends BaseViewModel with AsyncOperationMixin {
  // ViewModel implementation
}
```

### 3. Service Interfaces

Services implement specific interfaces for better testability:

```dart
abstract class ProcrustesServiceInterface {
  Future<ProcrustesResult> alignObjects(Object3D objectA, Object3D objectB);
  ProcrustesResult alignPoints(List<Vector3> pointsA, List<Vector3> pointsB);
  // ... other methods
}
```

## Extension Points

### 1. Extension Registry

The `ExtensionRegistry` manages extension services:

```dart
// Register extension
ExtensionRegistry.registerExtension<MultiObjectComparisonExtension>(
  'multi_object_comparison',
  MultiObjectComparisonServiceImpl(),
  version: '1.0.0',
  description: 'Multi-object comparison service',
  dependencies: ['procrustes_service'],
);

// Get extension
final extension = ExtensionRegistry.getExtension<MultiObjectComparisonExtension>(
  'multi_object_comparison',
);
```

### 2. Future Extensions

#### Multi-Object Comparison
```dart
abstract class MultiObjectComparisonExtension extends ExtensionService {
  Future<MultiObjectComparisonResult> compareObjects(List<Object3D> objects);
  Future<SimilarityMatrix> getSimilarityMatrix(List<Object3D> objects);
  Future<List<ObjectSimilarity>> findMostSimilar(
    Object3D referenceObject,
    List<Object3D> candidates,
  );
}
```

#### Cloud Sync
```dart
abstract class CloudSyncExtension extends ExtensionService {
  Future<String> uploadObject(Object3D object);
  Future<Object3D?> downloadObject(String cloudId);
  Future<void> syncResults(ProcrustesResult result);
  Future<List<Object3D>> getCloudObjects();
}
```

#### AI-Based Auto-Alignment
```dart
abstract class AIAlignmentExtension extends ExtensionService {
  Future<ProcrustesResult> performAutoAlignment(Object3D objectA, Object3D objectB);
  Future<List<AlignmentSuggestion>> getAlignmentSuggestions(
    Object3D objectA,
    Object3D objectB,
  );
  Future<void> trainModel(List<TrainingData> trainingData);
}
```

## Testing Strategy

### 1. Unit Tests

#### Service Tests
```dart
group('ProcrustesAnalysis', () {
  test('should align two identical point sets perfectly', () {
    final result = ProcrustesAnalysis.align(identicalPoints, identicalPoints);
    expect(result.similarityScore, greaterThan(99.0));
  });
});
```

#### ViewModel Tests
```dart
group('ObjectViewModel', () {
  test('should update object B position', () {
    viewModel.updateObjectBPosition(newPosition);
    expect(viewModel.objectB?.position, equals(newPosition));
  });
});
```

### 2. Mock Services

Mock services for testing:

```dart
class MockProcrustesService implements ProcrustesServiceInterface {
  void setMockResults(List<ProcrustesResult> results) {
    _mockResults.addAll(results);
  }
  
  void setShouldThrowError(bool shouldThrow, [String? message]) {
    _shouldThrowError = shouldThrow;
    _errorMessage = message;
  }
}
```

### 3. Test Configuration

```dart
class TestConfiguration {
  static const bool runUnitTests = true;
  static const bool runIntegrationTests = true;
  static const bool runPerformanceTests = false;
  static const bool runMockTests = true;
}
```

## Dependency Injection

### 1. Service Registration

```dart
// Core services (singletons)
ServiceLocator.registerService<ProcrustesServiceInterface>(
  () => ProcrustesServiceImpl(),
  asSingleton: true,
);

// Domain services (factories)
ServiceLocator.registerService<ObjectLoaderServiceInterface>(
  () => ObjectLoaderServiceImpl(),
);
```

### 2. Test Services

```dart
// Register test services
ServiceLocator.registerTestServices();

// Get mock service
final mockService = ServiceLocator.get<ProcrustesServiceInterface>();
```

### 3. Environment Configuration

```dart
// Set environment
ServiceConfiguration.setEnvironment(ServiceConfiguration.testing);

// Check environment
if (ServiceConfiguration.isTesting) {
  // Use mock services
}
```

## Performance Considerations

### 1. Isolate Usage

CPU-intensive operations run in isolates:

```dart
final result = await ProcrustesIsolateService.runAnalysis(
  objectA,
  objectB,
  (progress) => updateProgress(progress),
);
```

### 2. Lazy Loading

Services are registered as lazy singletons:

```dart
ServiceLocator.registerService<ProcrustesServiceInterface>(
  () => ProcrustesServiceImpl(),
  asSingleton: true, // Lazy singleton
);
```

### 3. Memory Management

Proper disposal of resources:

```dart
@override
void dispose() {
  _isDisposed = true;
  super.dispose();
}
```

## Error Handling

### 1. Custom Exceptions

```dart
class ServiceNotRegisteredException<T> implements Exception {
  @override
  String toString() {
    return 'Service of type $T is not registered.';
  }
}
```

### 2. Graceful Degradation

```dart
// Get service with null safety
final service = ServiceLocator.instance.getOrNull<ProcrustesServiceInterface>();

if (service != null) {
  // Use service
} else {
  // Handle missing service
}
```

## Future Extensions

### 1. Multi-Object Comparison

- Compare multiple 3D objects simultaneously
- Generate similarity matrices
- Find most similar objects in a collection

### 2. Cloud Synchronization

- Upload/download objects to/from cloud
- Sync analysis results across devices
- Collaborative analysis features

### 3. AI-Based Auto-Alignment

- Machine learning-based alignment suggestions
- Automatic object alignment
- Training data collection and model improvement

### 4. Advanced Analytics

- Statistical analysis of object similarities
- Trend analysis over time
- Export to various formats (JSON, CSV, PDF)

## Best Practices

### 1. Service Design

- Implement specific interfaces
- Use dependency injection
- Provide mock implementations for testing

### 2. ViewModel Design

- Extend BaseViewModel
- Use mixins for common functionality
- Handle errors gracefully

### 3. Testing

- Write unit tests for all services
- Use mock services for testing
- Test error conditions

### 4. Extension Development

- Follow the ExtensionService interface
- Validate dependencies
- Provide proper metadata

## Conclusion

This modular architecture provides:

- **Testability**: All components can be unit tested
- **Extensibility**: Easy to add new features via extensions
- **Maintainability**: Clear separation of concerns
- **Performance**: Efficient resource management
- **Scalability**: Support for future features

The architecture supports the current Procrustes analysis functionality while providing extension points for future features like multi-object comparison, cloud sync, and AI-based auto-alignment.
