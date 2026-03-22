import Cocoa
import Carbon

class PasteSimulator {
    /// Simulate Cmd+V paste action
    static func simulatePaste() {
        // Create key down event for Cmd+V
        let keyVDown = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true) // V key
        keyVDown?.flags = .maskCommand
        
        // Create key up event for Cmd+V
        let keyVUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false)
        keyVUp?.flags = .maskCommand
        
        // Post events
        keyVDown?.post(tap: .cghidEventTap)
        
        // Small delay between key down and up
        usleep(10000) // 10ms
        
        keyVUp?.post(tap: .cghidEventTap)
    }
    
    /// Alternative method using AppleScript (if CGEvent doesn't work)
    static func simulatePasteWithAppleScript() {
        let script = """
        tell application "System Events"
            keystroke "v" using {command down}
        end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }
}
