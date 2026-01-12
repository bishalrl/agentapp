# Project Structure

## Complete Directory Tree

```
lib/
├── core/                           # Shared core functionality
│   ├── constants/
│   │   ├── api_constants.dart     # API endpoints
│   │   └── app_constants.dart     # App constants
│   ├── errors/
│   │   ├── exceptions.dart        # Exception classes
│   │   └── failures.dart          # Failure classes
│   ├── network/
│   │   └── api_client.dart        # HTTP client
│   └── utils/
│       ├── network_info.dart      # Network checker
│       └── result.dart            # Result type
│
├── features/                       # Feature modules
│   ├── onboarding/                # Onboarding feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── onboarding_local_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── onboarding_model.dart
│   │   │   └── repositories/
│   │   │       └── onboarding_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── onboarding_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── onboarding_repository.dart
│   │   │   └── usecases/
│   │   │       ├── complete_onboarding.dart
│   │   │       └── get_onboarding_status.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── onboarding_page.dart
│   │
│   ├── bus_driver/                # Bus driver feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── driver_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── driver_model.dart
│   │   │   └── repositories/
│   │   │       └── driver_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── driver_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── driver_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_assigned_buses.dart
│   │   │       ├── get_driver_profile.dart
│   │   │       └── verify_driver_otp.dart
│   │   └── presentation/
│   │       └── pages/
│   │           └── driver_login_page.dart
│   │
│   └── booking/                   # Booking feature
│       ├── data/
│       │   ├── datasources/
│       │   │   └── booking_remote_data_source.dart
│       │   ├── models/
│       │   │   └── booking_model.dart
│       │   └── repositories/
│       │       └── booking_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── booking_entity.dart
│       │   ├── repositories/
│       │   │   └── booking_repository.dart
│       │   └── usecases/
│       │       ├── create_booking.dart
│       │       └── get_available_buses.dart
│       └── presentation/
│           └── pages/
│               └── booking_list_page.dart
│
└── main.dart                      # App entry point
```

## Layer Responsibilities

### Core Layer
- **Constants**: API endpoints, app-wide constants
- **Errors**: Exception and failure classes
- **Network**: HTTP client wrapper
- **Utils**: Shared utilities (network info, result type)

### Feature Layers

#### Data Layer
- **Data Sources**: Remote (API) and Local (cache/storage) data sources
- **Models**: Data models that extend domain entities
- **Repositories**: Concrete implementations of domain repository interfaces

#### Domain Layer
- **Entities**: Pure business objects (no dependencies)
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Business logic operations

#### Presentation Layer
- **Pages**: Screen widgets
- **Widgets**: Reusable UI components (to be added)
- **Providers**: State management (to be added)

## Feature Summary

| Feature | Purpose | Key Use Cases |
|---------|---------|---------------|
| **onboarding** | First-time user experience | Get status, Complete onboarding |
| **bus_driver** | Driver authentication & management | Verify OTP, Get profile, Get assigned buses |
| **booking** | Bus booking operations | Create booking, Get available buses |

## File Count

- **Core**: 7 files
- **Onboarding**: 7 files
- **Bus Driver**: 8 files
- **Booking**: 7 files
- **Total**: 29 files (excluding main.dart)

## Next Steps for Development

1. Add dependency injection setup
2. Implement secure token storage
3. Add state management (Provider/Bloc/Riverpod)
4. Create more presentation widgets
5. Add error handling UI
6. Implement offline support
7. Add unit tests for each layer

