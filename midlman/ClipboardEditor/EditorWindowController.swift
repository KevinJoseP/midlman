import SwiftUI
import Cocoa

class EditorWindowController: NSObject {
    private var window: NSWindow?
    private var hostingView: NSHostingView<EditorView>?

    // MARK: - Public API

    func show(with text: String, completion: @escaping (String?) -> Void) {
        let editorView = EditorView(
            initialText: text,
            onConfirm: { editedText in
                completion(editedText)
            },
            onCancel: { [weak self] in
                self?.hide()
                completion(nil)
            }
        )

        hostingView = NSHostingView(rootView: editorView)

        // Window geometry
        let windowWidth: CGFloat = 520
        let windowHeight: CGFloat = 340
        guard let screen = NSScreen.main else { return }
        let screenRect = screen.visibleFrame
        let windowRect = NSRect(
            x: screenRect.midX - windowWidth / 2,
            y: screenRect.midY - windowHeight / 2,
            width: windowWidth,
            height: windowHeight
        )

        window = BorderlessWindow(
            contentRect: windowRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window?.backgroundColor = .clear
        window?.isOpaque = false
        window?.hasShadow = true
        window?.level = .floating
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window?.contentView = hostingView
        window?.isReleasedWhenClosed = false

        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func hide() {
        window?.close()
        window = nil
        hostingView = nil
    }
}

// MARK: - Custom window

class BorderlessWindow: NSWindow {
    override var canBecomeKey: Bool  { true }
    override var canBecomeMain: Bool { true }
}

