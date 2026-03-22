import Cocoa
import Carbon

class KeyboardMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let callback: () -> Void
    
    // Track which keys are currently pressed
    private var cmdPressed = false
    private var optionPressed = false
    private var vPressed = false
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
        setupEventTap()
    }
    
    deinit {
        stop()
    }
    
    private func setupEventTap() {
        // Create event tap for key down and key up events
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
                let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(refcon).takeUnretainedValue()
                return monitor.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap")
            return
        }
        
        self.eventTap = eventTap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        // Handle flags changed (for modifier keys)
        if type == .flagsChanged {
            let flags = event.flags
            cmdPressed = flags.contains(.maskCommand)
            optionPressed = flags.contains(.maskAlternate)
        }
        
        // Handle key down
        if type == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            
            // V key = 9
            if keyCode == 9 { // V
                vPressed = true
            }
            
            // Check if Cmd+Option+V are all pressed
            if cmdPressed && optionPressed && vPressed {
                // Trigger callback
                DispatchQueue.main.async {
                    self.callback()
                }
                
                // Reset state
                vPressed = false
                
                // Consume the event to prevent actual paste (or other system action)
                return nil
            }
        }
        
        // Handle key up
        if type == .keyUp {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            
            if keyCode == 9 { // V
                vPressed = false
            }
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        
        eventTap = nil
        runLoopSource = nil
    }
}
