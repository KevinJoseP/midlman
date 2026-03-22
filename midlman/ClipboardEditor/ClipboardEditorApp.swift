import SwiftUI
import ServiceManagement

@main
struct ClipboardEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var keyboardMonitor: KeyboardMonitor?
    var editorWindowController: EditorWindowController?
    var statusItem: NSStatusItem?
    var previousApp: NSRunningApplication?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock
        NSApp.setActivationPolicy(.accessory)

        // Auto-enable Launch at Login if this is the first run / not registered
        if SMAppService.mainApp.status == .notRegistered {
            try? SMAppService.mainApp.register()
        }

        // Create menu bar icon
        setupMenuBar()

        // Initialize editor window controller
        editorWindowController = EditorWindowController()

        // Start keyboard monitor if permission already granted, otherwise wait for it
        if AXIsProcessTrusted() {
            startKeyboardMonitor()
        } else {
            requestAccessibilityAndWait()
        }
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "pencil.circle", accessibilityDescription: "midlman")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About midlman", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin(_:)), keyEquivalent: "")
        launchItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(launchItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
                sender.state = .off
            } else {
                try SMAppService.mainApp.register()
                sender.state = .on
            }
        } catch {
            print("Failed to toggle Launch at Login: \(error)")
        }
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "midlman"
        alert.informativeText = "Quick edit your clipboard content before pasting.\n\nPress Cmd+Option+V to open the editor."
        alert.alertStyle = .informational
        alert.runModal()
    }
    
    func startKeyboardMonitor() {
        keyboardMonitor = KeyboardMonitor { [weak self] in
            self?.showEditor()
        }
    }

    func requestAccessibilityAndWait() {
        // Trigger the system permission prompt
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options)

        // Open System Settings directly to the Accessibility page
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }

        // Poll every second until permission is granted, then start automatically
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            if AXIsProcessTrusted() {
                timer.invalidate()
                self?.startKeyboardMonitor()
            }
        }
    }
    
    func showEditor() {
        // Remember the currently active application (before we show our window)
        previousApp = NSWorkspace.shared.frontmostApplication
        
        // Get clipboard content
        let clipboardText = ClipboardManager.shared.readClipboard()
        
        // Show editor window with clipboard content
        editorWindowController?.show(with: clipboardText) { [weak self] editedText in
            if let editedText = editedText {
                // Hide window first
                self?.editorWindowController?.hide()
                
                // Write edited text to clipboard
                ClipboardManager.shared.writeToClipboard(editedText)
                
                // Restore focus to the previous application
                if let previousApp = self?.previousApp {
                    previousApp.activate(options: .activateIgnoringOtherApps)
                }
                
                // Wait for focus to restore and clipboard to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Simulate paste
                    PasteSimulator.simulatePaste()
                }
            }
        }
    }
}
