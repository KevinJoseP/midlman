# midlman — Spec

A native macOS menu bar app that intercepts `Cmd+Option+V`, lets the user edit clipboard text in a floating overlay, then auto-pastes the edited result.

---

## Core User Flow

1. User copies text normally (`Cmd+C`)
2. User presses `Cmd+Option+V` (instead of `Cmd+V`)
3. Floating editor overlay appears with clipboard content pre-loaded
4. User edits text
5. User presses `Enter` → edited text is written to clipboard and auto-pasted into the previous app
6. User presses `ESC` → editor closes, clipboard unchanged

---

## Components

### `KeyboardMonitor`
- Uses `CGEvent.tapCreate` at `.cgSessionEventTap` to intercept global key events
- Tracks `Cmd`, `Option`, `V` independently via `flagsChanged` + `keyDown`/`keyUp`
- On `Cmd+Option+V`: fires callback, **consumes the event** (returns `nil`) to suppress native paste
- Requires Accessibility permission

### `ClipboardManager` (singleton)
- `readClipboard() → String` — reads `NSPasteboard.general` string
- `writeToClipboard(_ text: String)` — clears and writes string to pasteboard
- `hasText() → Bool`

### `EditorWindowController`
- Creates a borderless, floating `NSWindow` (`.floating` level, joins all spaces)
- Hosts `EditorView` via `NSHostingView`
- Window: 520×340pt, centered on main screen, always on top
- `show(with:completion:)` — displays window, receives edited text or `nil` on cancel
- `hide()` — closes and deallocates window/hosting view

### `EditorView` (SwiftUI)
- Pre-populated `TextEditor` with monospaced font, auto-focused on appear
- `Enter` → calls `onConfirm(text)` (paste)
- `Shift+Enter` → inserts a newline
- `Esc` → calls `onCancel()`
- Glassmorphism styling: `.ultraThinMaterial`, rounded corners (16pt), gradient border

### `PasteSimulator`
- Primary: `CGEvent` key down/up for `Cmd+V` posted to `.cghidEventTap`
- Fallback: AppleScript `keystroke "v" using {command down}`

### `AppDelegate`
- Sets activation policy to `.accessory` (hidden from Dock)
- Menu bar icon: `pencil.circle` SF Symbol with "About" + "Quit" items
- On `Cmd+Option+V` trigger:
  1. Captures `NSWorkspace.shared.frontmostApplication`
  2. Reads clipboard
  3. Shows editor
  4. On confirm: writes edited text → clipboard, restores previous app focus, waits 100ms, simulates paste

---

## Permissions Required
- **Accessibility** (`AXIsProcessTrustedWithOptions`) — for global key tap and paste simulation

## Platform
- macOS 14+ (uses `.onKeyPress`, `@FocusState`)
- SwiftUI + AppKit hybrid
- Xcode project: `midlman/midlman.xcodeproj`
- Bundle entitlements: `ClipboardEditor.entitlements`
