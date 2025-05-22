# fleeting_light_journal

English | [中文](README.md)

Fleeting Light Journal - A Flutter application for emotional recording and reflection.

## Project Overview

This project aims to help users record daily emotions, memories, and important moments in card format. It supports multi-platform operation with a clean and beautiful interface, local data persistence, and local notification reminders.

## Directory Structure & Main Modules

```
lib/
├── main.dart                   // Application entry point
├── models/                     // Data models
│   └── memory_card.dart        // Memory card data structure
├── screens/                    // Pages and interfaces
│   ├── home_screen.dart        // Home page, displays all memory cards
│   ├── create_memory_card_screen.dart // Create memory card page
│   └── memory_card_screen.dart // Memory card detail page
├── services/                   // Business logic and services
│   ├── database_service.dart   // Database operation wrapper
│   └── notification_service.dart // Local notification service
├── theme/                      // Theme and styles
│   └── app_theme.dart          // Global theme configuration
└── widgets/                    // Reusable components
    └── memory_card_item.dart   // Memory card display component
```

### Main Module Descriptions
- **models/**: Defines core data structures such as memory cards.
- **screens/**: Contains main interface, card creation and detail pages, responsible for UI display and interaction.
- **services/**: Encapsulates core services like database operations (CRUD) and local notifications.
- **theme/**: Unified management of application themes, colors, and fonts.
- **widgets/**: Abstract reusable UI components to improve development efficiency.

## Quick Start

1. Clone the project locally

2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the project:
   ```bash
   flutter run
   ```

## Dependencies
- State management: provider
- Data persistence: sqflite, path_provider
- UI components and animations: flutter_staggered_grid_view, animations, flutter_markdown
- Local notifications: flutter_local_notifications
- Others: intl, image_picker, cached_network_image, etc.

## Development Recommendations
- Follow modular and component-based development for easy maintenance and extension.
- Recommend using Provider for state management.
- Unify themes and styles configuration in the theme directory.
- Database and notification services should be called through service classes in the services directory.

---

For more Flutter resources, please refer to:
- [Flutter Official Documentation](https://docs.flutter.dev/)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
