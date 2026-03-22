import SwiftUI

struct EditorView: View {
    @State private var text: String
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @FocusState private var isTextFieldFocused: Bool

    init(
        initialText: String,
        onConfirm: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _text = State(initialValue: initialText)
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Header ──────────────────────────────────────────────────────
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Midlman Quick Edit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                // Close button
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Cancel (⎋ ESC)")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)

            Divider()

            // ── Text Editor ─────────────────────────────────────────────────
            TextEditor(text: $text)
                .focused($isTextFieldFocused)
                .font(.system(size: 14, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(16)
                .background(Color(nsColor: .textBackgroundColor).opacity(0.3))
                .autocorrectionDisabled()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isTextFieldFocused = true
                    }
                }

            Divider()

            // ── Footer ──────────────────────────────────────────────────────
            HStack {
                // Left: paste shortcut
                HStack(spacing: 4) {
                    kbd("↵")
                    Text("Paste")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Centre: Newline shortcut
                HStack(spacing: 4) {
                    kbd("⇧↵")
                    Text("Newline")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Right: cancel
                HStack(spacing: 4) {
                    kbd("ESC")
                    Text("Cancel")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Key intercept ---------------------------------------------------
        .onKeyPress(phases: .down) { press in
            let mods = press.modifiers

            // Shift+Enter or Cmd+Enter → let TextEditor handle it as a newline
            if press.key == .return && (mods.contains(.shift) || mods.contains(.command)) {
                return .ignored
            }

            // Enter (no modifiers) → paste/confirm
            if press.key == .return {
                onConfirm(text)
                return .handled
            }

            // Esc → cancel
            if press.key == .escape {
                onCancel()
                return .handled
            }

            return .ignored
        }
    }

    // Small keyboard-badge helper
    @ViewBuilder
    private func kbd(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(.secondary)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.secondary.opacity(0.25), lineWidth: 0.5)
                    )
            )
    }
}

#Preview {
    EditorView(
        initialText: "Sample clipboard text\nEdit me!",
        onConfirm: { text in print("Confirmed: \(text)") },
        onCancel: { print("Cancelled") }
    )
    .frame(width: 520, height: 340)
}
