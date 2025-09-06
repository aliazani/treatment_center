# Treatment Center Assessment Tool

## Structural Rapid Assessment Tool for Treatment Centers During Ebola and Marburg Outbreaks

![Flutter](https://img.shields.io/badge/Flutter-3.7.0-blue)
![Dart](https://img.shields.io/badge/Dart-3.0.0-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green)
![State Management](https://img.shields.io/badge/State%20Management-BLoC-purple)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-orange)
![Tests](https://github.com/aliazani/treatment_center/actions/workflows/flutter-test.yml/badge.svg)

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Key Components](#key-components)
- [Testing](#testing)
- [Export Capabilities](#export-capabilities)
- [Contributing](#contributing)
- [License](#license)

## 🏥 Overview

The **Treatment Center Assessment Tool** is a comprehensive mobile and web application designed to conduct rapid structural assessments of healthcare facilities during Filovirus Disease (FVD) outbreaks, specifically Ebola and Marburg. This tool enables healthcare workers, facility managers, and assessment teams to systematically evaluate treatment centers across multiple critical dimensions.

### Purpose

- **Rapid Assessment**: Quickly evaluate treatment center readiness and capabilities
- **Standardized Evaluation**: Ensure consistent assessment across different facilities
- **Data-Driven Decisions**: Generate comprehensive reports for informed decision-making
- **Outbreak Response**: Support rapid deployment and setup of treatment facilities

## ✨ Features

### Core Functionality

#### 📊 Multi-Section Assessment System
- **Section 1: General Information**
  - Assessor information tracking
  - Geographical location mapping
  - Facility identification and classification
  - Healthcare services documentation
  
- **Section 2: Infrastructure Assessment**
  - Physical structure evaluation
  - Facility access and patient flow analysis
  - Safety and security measures
  
- **Section 3: Operational Assessment**
  - Screening and triage capabilities
  - Temporary isolation facilities
  - Clinical consultation areas
  
- **Section 4: Specialized Treatment Assessment**
  - FVD-specific treatment ward evaluation
  - Equipment reprocessing capabilities
  - Laundry and waste management

#### 📈 Advanced Features

- **Real-time Progress Tracking**: Visual indicators showing assessment completion
- **Dynamic Scoring System**: 
  - 5-point rating scale (Does not meet, Partially meets, Meets target, Don't Know, Not Applicable)
  - Automatic score calculation and performance metrics
  
- **Photo Documentation**: 
  - Camera integration for real-time photo capture
  - Gallery import for existing documentation
  - Photo annotation and categorization

#### 📱 Multi-Platform Support

- **Responsive Design**: Optimized for mobile, tablet, and desktop
- **Orientation Support**: 
  - Portrait mode with bottom navigation
  - Landscape mode with side navigation panel
  - Adaptive layouts for different screen sizes

#### 💾 Data Management

- **Offline Capability**: Full functionality without internet connection
- **Local Database**: SQLite/Drift for persistent storage
- **Auto-save**: Automatic progress saving
- **Data Validation**: Real-time form validation and error handling

#### 📤 Export Capabilities

- **Multiple Formats**:
  - **PDF**: Professional reports with charts and visualizations
  - **Excel**: Detailed data sheets with pivot-ready formatting
  - **Word**: Editable documents for further customization
  
- **Export Options**:
  - Include/exclude statistical analysis
  - Section-by-section breakdown
  - Photo attachment capability
  - Custom metadata inclusion

#### 📊 Dashboard & Analytics

- **Visual Statistics**: 
  - Progress charts and completion rates
  - Performance distribution graphs
  - Section-wise analysis
  
- **Summary Reports**:
  - Overall facility score

## 🏗️ Architecture

### Clean Architecture Implementation

The application follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                      # Core functionality and shared resources
│   ├── database/             # Database configuration and tables
│   ├── error/                # Error handling and failures
│   ├── network/              # Network services
│   ├── providers/            # File Service providers
│   └── services/             # Import / Export services
│
├── features/                 # Feature modules
│   ├── questionnaire_form/   # Main assessment feature
│   │   ├── data/             # Data layer
│   │   │   ├── datasources/  # Local and remote data sources
│   │   │   ├── models/       # Data models
│   │   │   └── repositories/ # Repository implementations
│   │   │
│   │   ├── domain/           # Domain layer (business logic)
│   │   │   ├── entities/     # Business entities
│   │   │   ├── repositories/ # Repository contracts
│   │   │   └── usecases/     # Business use cases
│   │   │
│   │   └── presentation/     # Presentation layer
│   │       ├── bloc/         # BLoC state management
│   │       ├── pages/        # Screen pages
│   │       └── widgets/      # Reusable widgets
│   └── geolocation           # geolocation dropdown + country code feature
│       ├── data/             # Data layer
│       │   ├── datasources/  # Local and remote data sources
│       │   ├── models/       # Data models
│       │   └── repositories/ # Repository implementations
│       │
│       ├── domain/           # Domain layer (business logic)
│       │   ├── entities/     # Business entities
│       │   ├── repositories/ # Repository contracts
│       │   └── usecases/     # Business use cases
│       │
│       └── presentation/     # Presentation layer
│           ├── bloc/         # BLoC state management
│           ├── pages/        # Screen pages
│           └── widgets/      # Reusable widgets
```

### Design Patterns

- **Repository Pattern**: Abstract data source implementation
- **Use Cases**: Encapsulated business logic
- **Dependency Injection**: GetIt for service location
- **BLoC Pattern**: Predictable state management
- **Factory Pattern**: Dynamic service creation

### Key Dependencies

```yaml
# State Management & Architecture
flutter_bloc: ^9.1.1          # BLoC state management
get_it: ^8.0.3               # Dependency injection
equatable: ^2.0.7            # Value equality
fpdart: ^1.1.1               # Functional programming

# Data Persistence
drift: ^2.28.0               # SQL database
shared_preferences: ^2.5.3   # Key-value storage
path_provider: ^2.1.5        # File system paths

# Export & Documentation
pdf: ^3.11.3                 # PDF generation
excel: ^4.0.6                # Excel file creation
printing: ^5.14.2            # Print and share
camera: ^0.11.0              # Camera integration
image_picker: ^1.2.1         # Photo selection
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: >=3.7.0
- Dart SDK: >=3.0.0
- Android Studio / Xcode (for mobile development)
- Chrome (for web development)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/treatment_center.git
cd treatment_center
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code (for code generation)**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the application**
```bash
# For mobile
flutter run

# For web
flutter run -d chrome

# For specific device
flutter run -d [device_id]
```

### Configuration

1. **Environment Setup**
   - Copy `.env.example` to `.env`
   - Configure environment variables

2. **Database Initialization**
   - Database automatically initializes on first run
   - Migrations handled by Drift

## 📁 Project Structure

### Key Directories

- **`/lib/core`**: Shared functionality, utilities, and configurations
- **`/lib/features`**: Feature modules following clean architecture
- **`/assets`**: Images, fonts, and static resources
- **`/test`**: Unit and widget tests
- **`/integration_test`**: Integration tests

### Important Files

- **`main.dart`**: Application entry point
- **`injection_container.dart`**: Dependency injection setup
- **`app_database.dart`**: Database configuration
- **`assessment_form_bloc.dart`**: Main state management

## 🔑 Key Components

### Assessment Form Entity
The core business entity representing a complete assessment:
- Assessor information
- Facility identification
- Multiple assessment sections
- Photo documentation
- Scoring and ratings

### BLoC State Management
- **Events**: User interactions and system events
- **States**: Application state representations
- **Bloc**: Business logic and state transitions

### Export System
- **ExportService**: Abstract export interface
- **PdfExportService**: PDF generation with charts
- **ExcelExportService**: Spreadsheet creation
- **DocExportService**: Word document generation

### Photo Management
- **PhotoPickerWidget**: Camera and gallery integration
- **PhotoEntity**: Photo metadata and storage
- **ImageCompression**: Automatic image optimization

## 🧪 Testing

### Test Coverage

- **Unit Tests**: Business logic and use cases
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end workflows

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/questionnaire_form/domain/usecases/

# Run integration tests
flutter test integration_test/
```

### Test Organization

```
test/
├── core/                    # Core functionality tests
├── features/               # Feature-specific tests
│    │── questionnaire_form/
│    │    ├── data/          # Data layer tests
│    │    ├── domain/        # Domain layer tests
│    │    └── presentation/  # Presentation tests
│    │
│    └── geolocation/
│        ├── data/          # Data layer tests
│        ├── domain/        # Domain layer tests
│        └── presentation/  # Presentation tests
└── fixtures/              # Test data and mocks
```

## 📤 Export Capabilities

### PDF Export Features
- Professional formatting with headers and footers
- Charts and visualizations
- Photo integration
- Digital signatures support
- Customizable templates

### Excel Export Features
- Multiple worksheets (Summary, Sections, Analysis)
- Conditional formatting
- Pivot-ready data structure
- Formula calculations
- Charts and graphs

### Word Export Features
- Editable document format
- Structured sections
- Table of contents
- Image embedding
- Comment support

## 🛠️ Development Guidelines

### Code Style
- Follow Dart style guide
- Use `flutter_lints` for code analysis
- Maintain consistent naming conventions
- Document public APIs

### Git Workflow
1. Create feature branch from `develop`
2. Make atomic commits with clear messages
3. Write/update tests
4. Create pull request with description
5. Code review and merge

### Architecture Guidelines
- Maintain layer separation
- Use dependency injection
- Follow SOLID principles
- Implement error handling
- Write testable code

## 📱 Platform-Specific Features

### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Permissions: Camera, Storage

### iOS
- Minimum iOS: 12.0
- Permissions: Camera, Photo Library
- Info.plist configurations required

### Web
- Responsive design
- PWA support
- Local storage for offline capability
- Print functionality

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### How to Contribute
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## 📄 License

This project is licensed under the GPL2 License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- World Health Organization (WHO) for assessment guidelines
- Médecins Sans Frontières (MSF) for field insights
- Flutter team for the excellent framework
- Open source community for dependencies

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: treatmentcenter2025@gmail.com
- Documentation: [docs.treatmentcenter.org](https://docs.treatmentcenter.org)

---

**Version**: 1.0.0+1  
**Last Updated**: August 2025  
**Status**: Production Ready

*Built with ❤️ for healthcare workers on the frontlines of disease outbreaks*
