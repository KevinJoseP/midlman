<br/>
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/placeholder-dark">
    <img alt="midlman" width="120" src="https://github.com/user-attachments/assets/placeholder-light">
  </picture>
</p>

<h1 align="center">midlman</h1>

<p align="center">
  <strong>The missing step between Copy and Paste.</strong>
</p>

<p align="center">
  A native macOS menu-bar utility that intercepts your paste,<br/>
  lets you edit the clipboard on the fly, and pastes the result — all in one keystroke.
</p>

<p align="center">
  <a href="https://github.com/KevinJoseP/midlman/releases/latest">
    <img src="https://img.shields.io/badge/-Download_DMG-000000?style=for-the-badge&logo=apple&logoColor=white" alt="Download DMG" />
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS_14+-111111?style=flat-square&logo=apple&logoColor=white" />
  <img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat-square&logo=swift&logoColor=white" />
  <img src="https://img.shields.io/github/license/KevinJoseP/midlman?style=flat-square&color=blue" />
  <img src="https://img.shields.io/github/v/release/KevinJoseP/midlman?style=flat-square&label=latest&color=green" />
  <img src="https://img.shields.io/badge/100%25-local_&_private-purple?style=flat-square" />
</p>

<br/>

<p align="center">
  <img src="https://github.com/user-attachments/assets/placeholder-demo" alt="midlman demo" width="600" />
</p>

<p align="center"><em>Press <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> → Edit → Press <kbd>↵</kbd> → Pasted.</em></p>

<br/>

---

<br/>

## The Problem

You copy a URL, a snippet, a message — but before pasting, you need to tweak it. Remove a tracking parameter. Fix a typo. Strip extra whitespace. Trim a quote.

So you open a scratchpad, paste, edit, copy again, switch back, paste. **Five steps for a one-second fix.**

## The Solution

**midlman** sits invisibly in your menu bar. When you press <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd>, a minimal floating editor appears with your clipboard contents, ready to edit. Press <kbd>↵ Enter</kbd> and the edited text is pasted directly into whatever app you were using. That's it.

No Dock icon. No window to manage. No data leaves your machine.

<br/>

---

<br/>

## Install

### Download (recommended)

1. **[Download the latest DMG](https://github.com/KevinJoseP/midlman/releases/latest)** from GitHub Releases
2. Open the `.dmg` and drag **midlman** to your Applications folder
3. Launch midlman — look for the **pencil icon** in your menu bar
4. **Grant Accessibility permission** when prompted

> [!IMPORTANT]
> Since the app is not notarized with a paid Apple Developer account, macOS will show a warning on first launch.
> Simply **right-click the app → Open** to bypass it. This is a one-time step.

### Build from source

```bash
git clone https://github.com/KevinJoseP/midlman.git
cd midlman/midlman
open midlman.xcodeproj
```

In Xcode: set your **Signing Team**, then hit <kbd>⌘</kbd><kbd>R</kbd> to build and run.

**Requires:** macOS 14 Sonoma or later, Xcode 15+

<br/>

---

<br/>

## Usage

### The basics

<table>
<tr>
<td width="50%" valign="top">

**1. Copy something as usual**

Copy any text with <kbd>⌘</kbd><kbd>C</kbd> — a link, code snippet, message, anything.

</td>
<td width="50%" valign="top">

**2. Invoke midlman**

Press <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> instead of the regular paste shortcut. A floating editor appears instantly with your clipboard contents.

</td>
</tr>
<tr>
<td width="50%" valign="top">

**3. Edit freely**

The editor is a full text field — add, remove, rearrange. Use <kbd>⇧</kbd><kbd>↵</kbd> for new lines. The monospaced font keeps things readable.

</td>
<td width="50%" valign="top">

**4. Paste in one shot**

Press <kbd>↵ Enter</kbd> — the editor closes, your previous app regains focus, and the edited text is pasted automatically. Done.

</td>
</tr>
</table>

### Keyboard shortcuts

| Shortcut | Action |
|:---------|:-------|
| <kbd>⌘</kbd> <kbd>⌥</kbd> <kbd>V</kbd> | Open the editor with current clipboard |
| <kbd>↵</kbd> Enter | Confirm edit and paste into the target app |
| <kbd>⇧</kbd> <kbd>↵</kbd> Shift+Enter | Insert a new line inside the editor |
| <kbd>⌘</kbd> <kbd>↵</kbd> Cmd+Enter | Insert a new line inside the editor |
| <kbd>ESC</kbd> | Cancel — close the editor, clipboard unchanged |

### Menu bar options

Click the pencil icon in the menu bar to access:

- **About midlman** — version info and shortcut reminder
- **Launch at Login** — toggle to start midlman automatically when you log in
- **Quit** — exit midlman

### Use cases

| Scenario | What you'd do |
|:---------|:-------------|
| **Clean a URL** | Copy a link with UTM params → <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> → delete the `?utm_...` suffix → <kbd>↵</kbd> |
| **Fix a typo before sending** | Copy a message → <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> → fix the typo → <kbd>↵</kbd> |
| **Trim whitespace** | Copy text with leading/trailing spaces → <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> → trim → <kbd>↵</kbd> |
| **Extract part of a block** | Copy a paragraph → <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> → keep only the sentence you need → <kbd>↵</kbd> |
| **Reformat a snippet** | Copy a code block → <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> → adjust indentation or syntax → <kbd>↵</kbd> |
| **Compose from clipboard** | Copy a name/value → <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> → wrap it in a sentence → <kbd>↵</kbd> |

<br/>

---

<br/>

## How it works under the hood

```
  ┌─────────────┐     ┌──────────────────┐     ┌────────────────┐
  │  ⌘ ⌥ V      │────▶│  KeyboardMonitor │────▶│  AppDelegate   │
  │  (hotkey)    │     │  (CGEvent tap)   │     │  .showEditor() │
  └─────────────┘     └──────────────────┘     └───────┬────────┘
                                                        │
                       ┌──────────────────┐             │
                       │ ClipboardManager │◀────────────┤
                       │ .readClipboard() │             │
                       └───────┬──────────┘             │
                               │                        ▼
                               │              ┌──────────────────┐
                               └─────────────▶│   EditorWindow   │
                                              │   (floating UI)  │
                                              └────────┬─────────┘
                                                       │
                                              User edits text...
                                                       │
                                              Presses ↵ Enter
                                                       │
                                                       ▼
                       ┌──────────────────┐   ┌──────────────────┐
                       │ ClipboardManager │◀──│   Write edited   │
                       │ .writeClipboard()│   │   text back      │
                       └───────┬──────────┘   └──────────────────┘
                               │
                               ▼
                       ┌──────────────────┐
                       │  Restore focus   │
                       │  to previous app │
                       └───────┬──────────┘
                               │  100ms delay
                               ▼
                       ┌──────────────────┐
                       │  PasteSimulator  │
                       │  (⌘V via CGEvent)│
                       └──────────────────┘
```

### Architecture

| Module | Responsibility |
|:-------|:--------------|
| **ClipboardEditorApp** | App entry point — SwiftUI lifecycle with AppKit bridge for menu bar and system integration |
| **KeyboardMonitor** | Installs a global `CGEvent` tap to intercept <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> at the session level |
| **ClipboardManager** | Singleton wrapper around `NSPasteboard` for reading and writing clipboard text |
| **EditorWindowController** | Creates and manages a borderless, always-on-top `NSWindow` that hosts the SwiftUI editor |
| **EditorView** | SwiftUI view with glassmorphic styling — translucent materials, gradient borders, keyboard shortcut badges |
| **PasteSimulator** | Simulates <kbd>⌘</kbd><kbd>V</kbd> via `CGEvent` posted to the HID event tap, with an AppleScript fallback |

### Design decisions

- **SwiftUI + AppKit hybrid** — SwiftUI handles the editor UI; AppKit handles the parts SwiftUI can't (global event taps, menu bar, borderless windows with keyboard focus)
- **CGEvent tap** — operates at the session level for reliable global hotkey detection without polling
- **Borderless floating window** — custom `NSWindow` subclass that overrides `canBecomeKey` and `canBecomeMain` to accept keyboard input despite having no title bar
- **100ms paste delay** — gives the target app time to regain focus before the simulated <kbd>⌘</kbd><kbd>V</kbd> arrives
- **No App Sandbox** — required for `CGEvent` taps to function; the app has zero network calls

<br/>

---

<br/>

## Permissions

midlman requires **Accessibility** permission to function. This is needed for two things:

1. **Intercepting** the global <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> shortcut (via `CGEvent` tap)
2. **Simulating** the <kbd>⌘</kbd><kbd>V</kbd> paste keystroke (via `CGEvent` post)

On first launch, the app will prompt you and open **System Settings → Privacy & Security → Accessibility**. Toggle midlman on, then the app will automatically detect the permission and start working.

> [!NOTE]
> No other permissions are required. midlman has zero network access — everything runs locally on your machine.

<br/>

---

<br/>

## Troubleshooting

| Issue | Solution |
|:------|:---------|
| <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd> does nothing | Open **System Settings → Privacy & Security → Accessibility** and make sure midlman is enabled. Restart the app after granting permission. |
| Editor appears but paste doesn't work | The target app may not have regained focus in time. Try again — if persistent, toggle Accessibility permission off and on. |
| "Unidentified developer" warning | Right-click the app → **Open**. This is a one-time macOS Gatekeeper prompt for non-notarized apps. |
| Editor doesn't show clipboard content | Make sure you've copied text (not an image/file) to the clipboard before pressing <kbd>⌘</kbd><kbd>⌥</kbd><kbd>V</kbd>. |
| App not in menu bar after launch | Check that the app is running (Activity Monitor → search "midlman"). If your menu bar is full, the icon may be hidden — try closing other menu bar apps. |

<br/>

---

<br/>

## Contributing

Contributions are welcome. If you have an idea or found a bug:

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Open a Pull Request

<br/>

---

<br/>

## License

[MIT](LICENSE) — free to use, modify, and distribute.

<br/>

<p align="center">
  <sub>Built with Swift and SwiftUI for macOS.</sub><br/>
  <sub>Made by <a href="https://github.com/KevinJoseP">Kevin Jose</a></sub>
</p>
