# Custom Dialog

This directory contains two implementations of a custom dialog widget:

1. **CustomDialog** (`src/custom_dialog.dart`) - Original implementation
2. **NewCustomDialog** (`src/new_custom_dialog.dart`) - Refactored, cleaner implementation

## NewCustomDialog (Recommended)

The `NewCustomDialog` is a complete rewrite of the original `CustomDialog` with the following improvements:

### Key Improvements

- **Cleaner Code Structure**: Organized into separate part files for better maintainability
- **Better Performance**: Optimized calculations with caching and reduced rebuilds
- **Improved API**: More intuitive parameter names and better documentation
- **Type Safety**: Better enum usage and type definitions
- **Simplified State Management**: Cleaner internal state handling
- **Better Animation**: More consistent and smooth animations

### Features

- ✅ Position dialog relative to target widgets
- ✅ Optional arrow indicators pointing to target
- ✅ Keyboard-aware behavior (avoid/resize)
- ✅ Multiple alignment options
- ✅ Customizable styling (shadows, borders, etc.)
- ✅ Overflow prevention
- ✅ Smooth animations
- ✅ Performance optimizations

### Usage

```dart
import 'package:your_app/share_code/custom_dialog/src/new_custom_dialog.dart';

// Basic usage
showDialog(
  context: context,
  builder: (context) => NewCustomDialog(
    context: context,
    child: YourContentWidget(),
  ),
);

// Advanced usage with target widget
showDialog(
  context: context,
  builder: (context) => NewCustomDialog(
    context: context,
    targetWidgetContext: targetButtonContext,
    alignment: DialogAlignment.right,
    showArrow: true,
    targetDistance: 10,
    avoidKeyboard: true,
    child: YourContentWidget(),
  ),
);
```

### Migration from CustomDialog

| Old Parameter                     | New Parameter       | Notes               |
| --------------------------------- | ------------------- | ------------------- |
| `alignTargetWidget`               | `alignment`         | Renamed for clarity |
| `enableArrow`                     | `showArrow`         | Renamed for clarity |
| `adjustment`                      | `positionOffset`    | Renamed for clarity |
| `pushDialogAboveWhenKeyboardShow` | `avoidKeyboard`     | Simplified name     |
| `distanceBetweenTargetWidget`     | `targetDistance`    | Shortened name      |
| `adjustSizeWhenKeyboardShow`      | `resizeForKeyboard` | Renamed for clarity |
| `static`                          | Removed             | No longer needed    |
| `followArrow`                     | Removed             | Simplified behavior |
| `showOverFlowArrow`               | Removed             | Simplified behavior |
| `overflowLeft`                    | Removed             | Simplified behavior |

### File Structure

```
src/
├── new_custom_dialog.dart          # Main dialog implementation
├── dialog_enums.dart               # Enum definitions (part file)
├── dialog_position_calculator.dart # Position calculation logic (part file)
├── dialog_arrow_painter.dart       # Arrow painting logic (part file)
├── new_custom_dialog_example.dart  # Usage examples
└── triangle.dart                   # Reused arrow painters
```

### Parameters

#### Required

- `context`: BuildContext - The context where dialog will be displayed
- `child`: Widget - Content to display inside the dialog

#### Optional Positioning

- `targetWidgetContext`: BuildContext? - Context of target widget to align to
- `alignment`: DialogAlignment - How to align relative to target (default: right)
- `positionOffset`: Offset - Additional position adjustment (default: Offset.zero)
- `targetDistance`: double - Distance from target widget (default: 0)

#### Optional Styling

- `height`: double? - Fixed height for dialog
- `width`: double? - Fixed width for dialog
- `borderRadius`: double - Corner radius (default: 10)
- `hasShadow`: bool - Whether to show shadow (default: false)

#### Optional Arrow

- `showArrow`: bool - Whether to show arrow (default: false)
- `arrowWidth`: double - Arrow width (default: 30)
- `arrowHeight`: double - Arrow height (default: 15)

#### Optional Behavior

- `dismissible`: bool - Can be dismissed by tapping outside (default: true)
- `avoidKeyboard`: bool - Move above keyboard when it appears (default: false)
- `resizeForKeyboard`: bool - Resize when keyboard appears (default: true)

#### Optional Callbacks

- `onTapOutside`: VoidCallback? - Called when tapping outside
- `onDismiss`: VoidCallback? - Called when dialog is dismissed

### Alignment Options

```dart
enum DialogAlignment {
  right,              // Align to right of target
  rightCenter,        // Align to right center of target
  left,               // Align to left of target
  leftCenter,         // Align to left center of target
  topCenter,          // Align above target (centered)
  bottomCenter,       // Align below target (centered)
  bottomLeft,         // Align below target (left-aligned)
  centerBottomRight,  // Align to bottom-right of target
}
```

### Performance Features

1. **Position Caching**: Expensive position calculations are cached
2. **Optimized Rebuilds**: Only rebuilds when necessary
3. **Efficient Animations**: Uses optimized animation controllers
4. **Memory Management**: Proper disposal of resources

### Examples

See `src/new_custom_dialog_example.dart` for comprehensive usage examples.

## Legacy CustomDialog

The original `CustomDialog` is still available for backward compatibility but is not recommended for new projects. Consider migrating to `NewCustomDialog` for better performance and maintainability.

## Dependencies

- `flutter/material.dart`
- `flutter_animate` - For smooth animations
- `keyboard_size_provider` - For keyboard detection
- Your app's theme extensions

## Contributing

When making changes to the dialog implementation:

1. Update both the main file and relevant part files
2. Add tests for new functionality
3. Update documentation and examples
4. Ensure backward compatibility when possible
