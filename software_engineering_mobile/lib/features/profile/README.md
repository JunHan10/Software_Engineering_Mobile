# ProfileV2 - Modular Profile Architecture

This directory contains the refactored profile functionality from `legacy_profile.dart`, split into a clean, modular architecture that separates UI components from business logic.

## 📁 Directory Structure

```
profile/
├── models/
│   ├── profile_state.dart        # State management and data models
│   └── profile_controller.dart   # State controller with business logic
├── services/
│   └── profile_service.dart      # Backend operations and data access
├── widgets/
│   ├── profile_app_bar.dart      # Profile header with navigation
│   ├── statistics_section.dart   # Loan statistics display
│   ├── wallet_card.dart          # Hippo Bucks balance and transactions
│   ├── gallery_section.dart      # Photo gallery management
│   └── activity_section.dart     # Recent activity display
├── ui/
│   └── profile_dialogs.dart      # Dialog components and utilities
└── profile_page_v2.dart          # Main page orchestrating all components
```

## 🏗️ Architecture Principles

### **Separation of Concerns**
- **UI Components** (`widgets/`): Pure UI widgets that receive data and callbacks
- **Business Logic** (`models/`, `services/`): Data processing and state management
- **Dialogs** (`ui/`): Reusable dialog components and utilities

### **State Management**
- **ProfileState**: Immutable state object containing all profile data
- **ProfileController**: ChangeNotifier that manages state and business operations
- **ProfileService**: Backend operations abstracted from UI

### **Dependency Injection**
- Services are injected through the controller
- UI components receive only the data they need
- Clean interfaces between layers

## 📋 Components Overview

### **ProfilePageV2** (Main Entry Point)
- Orchestrates all profile components
- Manages ProfileController lifecycle
- Handles error display and user feedback
- Uses CustomScrollView with Slivers for optimal scrolling

### **ProfileController** (State Management)
- Extends ChangeNotifier for reactive updates
- Manages ProfileState immutably
- Coordinates between UI and ProfileService
- Handles error states and loading indicators

### **ProfileService** (Backend Operations)
- User data loading and updating
- Image picking and management
- Hippo Bucks transactions
- Statistics loading
- Local storage operations

### **ProfileState** (Data Model)
- Immutable state object
- Contains all profile-related data
- Provides computed properties (displayName, isLoggedIn)
- Supports copyWith pattern for updates

## 🎨 UI Components

### **ProfileAppBar**
- Collapsible SliverAppBar with gradient background
- Profile image picker with loading states
- Navigation menu (Edit, Settings, Logout)
- Background patterns and user information display

### **StatisticsSection**
- Displays loan statistics in card format
- Reusable stat card components
- Color-coded icons and values

### **WalletCard**
- Hippo Bucks balance display
- Deposit/Withdraw functionality
- Transaction history access
- Gradient design with action buttons

### **GallerySection**
- Photo gallery management
- Add/remove image functionality
- Horizontal scrolling layout
- Empty state handling

### **ActivitySection**
- Recent activity display
- Icon-based activity items
- Time-based activity feed

### **ProfileDialogs**
- Transaction input dialogs
- Transaction history display
- Error handling dialogs
- Success feedback snackbars
