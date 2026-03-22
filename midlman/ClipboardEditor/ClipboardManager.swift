import Cocoa

class ClipboardManager {
    static let shared = ClipboardManager()
    
    private let pasteboard = NSPasteboard.general
    
    private init() {}
    
    /// Read text from clipboard
    func readClipboard() -> String {
        return pasteboard.string(forType: .string) ?? ""
    }
    
    /// Write text to clipboard
    func writeToClipboard(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    /// Check if clipboard contains text
    func hasText() -> Bool {
        return pasteboard.string(forType: .string) != nil
    }
}
