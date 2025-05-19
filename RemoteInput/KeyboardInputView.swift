import SwiftUI

#if os(iOS)
struct KeyboardInputView: View {
    let reportController: ReportController
    @Environment(\.dismiss) private var dismiss
    @State private var modifiers: Set<ModifierKey> = []
    
    enum ModifierKey: String, CaseIterable, Hashable {
        case shift = "⇧"
        case control = "⌃"
        case option = "⌥"
        case command = "⌘"
        
        var keyCode: UInt8 {
            switch self {
            case .shift: return HIDModifierFlags.LeftShift
            case .control: return HIDModifierFlags.LeftCtrl
            case .option: return HIDModifierFlags.LeftAlt
            case .command: return HIDModifierFlags.LeftMeta
            }
        }
    }
    
    struct Key: Identifiable, Hashable {
        let id = UUID()
        let label: String
        let shiftedLabel: String?
        let keyCode: UInt8
        let width: CGFloat
        let height: CGFloat
        let modifier: ModifierKey?
        
        init(label: String, shiftedLabel: String? = nil, keyCode: UInt8, width: CGFloat, height: CGFloat, modifier: ModifierKey? = nil) {
            self.label = label
            self.shiftedLabel = shiftedLabel
            self.keyCode = keyCode
            self.width = width
            self.height = height
            self.modifier = modifier
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: Key, rhs: Key) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    static let keys: [[Key]] = [
        [
            Key(label: "esc", keyCode: HIDKeyCodes.Escape, width: 1, height: 1, modifier: nil),
            Key(label: "F1", keyCode: HIDKeyCodes.F1, width: 1, height: 1, modifier: nil),
            Key(label: "F2", keyCode: HIDKeyCodes.F2, width: 1, height: 1, modifier: nil),
            Key(label: "F3", keyCode: HIDKeyCodes.F3, width: 1, height: 1, modifier: nil),
            Key(label: "F4", keyCode: HIDKeyCodes.F4, width: 1, height: 1, modifier: nil),
            Key(label: "F5", keyCode: HIDKeyCodes.F5, width: 1, height: 1, modifier: nil),
            Key(label: "F6", keyCode: HIDKeyCodes.F6, width: 1, height: 1, modifier: nil),
            Key(label: "F7", keyCode: HIDKeyCodes.F7, width: 1, height: 1, modifier: nil),
            Key(label: "F8", keyCode: HIDKeyCodes.F8, width: 1, height: 1, modifier: nil),
            Key(label: "F9", keyCode: HIDKeyCodes.F9, width: 1, height: 1, modifier: nil),
            Key(label: "F10", keyCode: HIDKeyCodes.F10, width: 1, height: 1, modifier: nil),
            Key(label: "F11", keyCode: HIDKeyCodes.F11, width: 1, height: 1, modifier: nil),
            Key(label: "F12", keyCode: HIDKeyCodes.F12, width: 1, height: 1, modifier: nil)
        ],
        [
            Key(label: "`", shiftedLabel: "~", keyCode: HIDKeyCodes.Grave, width: 1, height: 1, modifier: nil),
            Key(label: "1", shiftedLabel: "!", keyCode: HIDKeyCodes.Key1, width: 1, height: 1, modifier: nil),
            Key(label: "2", shiftedLabel: "@", keyCode: HIDKeyCodes.Key2, width: 1, height: 1, modifier: nil),
            Key(label: "3", shiftedLabel: "#", keyCode: HIDKeyCodes.Key3, width: 1, height: 1, modifier: nil),
            Key(label: "4", shiftedLabel: "$", keyCode: HIDKeyCodes.Key4, width: 1, height: 1, modifier: nil),
            Key(label: "5", shiftedLabel: "%", keyCode: HIDKeyCodes.Key5, width: 1, height: 1, modifier: nil),
            Key(label: "6", shiftedLabel: "^", keyCode: HIDKeyCodes.Key6, width: 1, height: 1, modifier: nil),
            Key(label: "7", shiftedLabel: "&", keyCode: HIDKeyCodes.Key7, width: 1, height: 1, modifier: nil),
            Key(label: "8", shiftedLabel: "*", keyCode: HIDKeyCodes.Key8, width: 1, height: 1, modifier: nil),
            Key(label: "9", shiftedLabel: "(", keyCode: HIDKeyCodes.Key9, width: 1, height: 1, modifier: nil),
            Key(label: "0", shiftedLabel: ")", keyCode: HIDKeyCodes.Key0, width: 1, height: 1, modifier: nil),
            Key(label: "-", shiftedLabel: "_", keyCode: HIDKeyCodes.Minus, width: 1, height: 1, modifier: nil),
            Key(label: "=", shiftedLabel: "+", keyCode: HIDKeyCodes.Equal, width: 1, height: 1, modifier: nil),
            Key(label: "delete", keyCode: HIDKeyCodes.Backspace, width: 1.5, height: 1, modifier: nil)
        ],
        [
            Key(label: "tab", keyCode: HIDKeyCodes.Tab, width: 1.5, height: 1, modifier: nil),
            Key(label: "q", shiftedLabel: "Q", keyCode: HIDKeyCodes.Q, width: 1, height: 1, modifier: nil),
            Key(label: "w", shiftedLabel: "W", keyCode: HIDKeyCodes.W, width: 1, height: 1, modifier: nil),
            Key(label: "e", shiftedLabel: "E", keyCode: HIDKeyCodes.E, width: 1, height: 1, modifier: nil),
            Key(label: "r", shiftedLabel: "R", keyCode: HIDKeyCodes.R, width: 1, height: 1, modifier: nil),
            Key(label: "t", shiftedLabel: "T", keyCode: HIDKeyCodes.T, width: 1, height: 1, modifier: nil),
            Key(label: "y", shiftedLabel: "Y", keyCode: HIDKeyCodes.Y, width: 1, height: 1, modifier: nil),
            Key(label: "u", shiftedLabel: "U", keyCode: HIDKeyCodes.U, width: 1, height: 1, modifier: nil),
            Key(label: "i", shiftedLabel: "I", keyCode: HIDKeyCodes.I, width: 1, height: 1, modifier: nil),
            Key(label: "o", shiftedLabel: "O", keyCode: HIDKeyCodes.O, width: 1, height: 1, modifier: nil),
            Key(label: "p", shiftedLabel: "P", keyCode: HIDKeyCodes.P, width: 1, height: 1, modifier: nil),
            Key(label: "[", shiftedLabel: "{", keyCode: HIDKeyCodes.LeftBracket, width: 1, height: 1, modifier: nil),
            Key(label: "]", shiftedLabel: "}", keyCode: HIDKeyCodes.RightBracket, width: 1, height: 1, modifier: nil),
            Key(label: "\\", shiftedLabel: "|", keyCode: HIDKeyCodes.Backslash, width: 1.5, height: 1, modifier: nil)
        ],
        [
            Key(label: "caps", keyCode: HIDKeyCodes.CapsLock, width: 1.75, height: 1, modifier: nil),
            Key(label: "a", shiftedLabel: "A", keyCode: HIDKeyCodes.A, width: 1, height: 1, modifier: nil),
            Key(label: "s", shiftedLabel: "S", keyCode: HIDKeyCodes.S, width: 1, height: 1, modifier: nil),
            Key(label: "d", shiftedLabel: "D", keyCode: HIDKeyCodes.D, width: 1, height: 1, modifier: nil),
            Key(label: "f", shiftedLabel: "F", keyCode: HIDKeyCodes.F, width: 1, height: 1, modifier: nil),
            Key(label: "g", shiftedLabel: "G", keyCode: HIDKeyCodes.G, width: 1, height: 1, modifier: nil),
            Key(label: "h", shiftedLabel: "H", keyCode: HIDKeyCodes.H, width: 1, height: 1, modifier: nil),
            Key(label: "j", shiftedLabel: "J", keyCode: HIDKeyCodes.J, width: 1, height: 1, modifier: nil),
            Key(label: "k", shiftedLabel: "K", keyCode: HIDKeyCodes.K, width: 1, height: 1, modifier: nil),
            Key(label: "l", shiftedLabel: "L", keyCode: HIDKeyCodes.L, width: 1, height: 1, modifier: nil),
            Key(label: ";", shiftedLabel: ":", keyCode: HIDKeyCodes.Semicolon, width: 1, height: 1, modifier: nil),
            Key(label: "'", shiftedLabel: "\"", keyCode: HIDKeyCodes.Apostrophe, width: 1, height: 1, modifier: nil),
            Key(label: "return", keyCode: HIDKeyCodes.Enter, width: 1.75, height: 1, modifier: nil)
        ],
        [
            Key(label: "⇧", keyCode: HIDKeyCodes.LeftShift, width: 2.25, height: 1, modifier: .shift),
            Key(label: "z", shiftedLabel: "Z", keyCode: HIDKeyCodes.Z, width: 1, height: 1, modifier: nil),
            Key(label: "x", shiftedLabel: "X", keyCode: HIDKeyCodes.X, width: 1, height: 1, modifier: nil),
            Key(label: "c", shiftedLabel: "C", keyCode: HIDKeyCodes.C, width: 1, height: 1, modifier: nil),
            Key(label: "v", shiftedLabel: "V", keyCode: HIDKeyCodes.V, width: 1, height: 1, modifier: nil),
            Key(label: "b", shiftedLabel: "B", keyCode: HIDKeyCodes.B, width: 1, height: 1, modifier: nil),
            Key(label: "n", shiftedLabel: "N", keyCode: HIDKeyCodes.N, width: 1, height: 1, modifier: nil),
            Key(label: "m", shiftedLabel: "M", keyCode: HIDKeyCodes.M, width: 1, height: 1, modifier: nil),
            Key(label: ",", shiftedLabel: "<", keyCode: HIDKeyCodes.Comma, width: 1, height: 1, modifier: nil),
            Key(label: ".", shiftedLabel: ">", keyCode: HIDKeyCodes.Dot, width: 1, height: 1, modifier: nil),
            Key(label: "/", shiftedLabel: "?", keyCode: HIDKeyCodes.Slash, width: 1, height: 1, modifier: nil),
            Key(label: "⇧", keyCode: HIDKeyCodes.RightShift, width: 2.75, height: 1, modifier: .shift)
        ],
        [
            Key(label: "fn", keyCode: HIDKeyCodes.Fn, width: 1, height: 1, modifier: nil),
            Key(label: "⌃", keyCode: HIDKeyCodes.LeftCtrl, width: 1, height: 1, modifier: .control),
            Key(label: "⌥", keyCode: HIDKeyCodes.LeftAlt, width: 1, height: 1, modifier: .option),
            Key(label: "⌘", keyCode: HIDKeyCodes.LeftMeta, width: 1, height: 1, modifier: .command),
            Key(label: "space", keyCode: HIDKeyCodes.Space, width: 4, height: 1, modifier: nil),
            Key(label: "⌘", keyCode: HIDKeyCodes.RightMeta, width: 1, height: 1, modifier: .command),
            Key(label: "⌥", keyCode: HIDKeyCodes.RightAlt, width: 1, height: 1, modifier: .option),
            Key(label: "⌃", keyCode: HIDKeyCodes.RightCtrl, width: 1, height: 1, modifier: .control),
            Key(label: "←", keyCode: HIDKeyCodes.Left, width: 1, height: 1, modifier: nil),
            Key(label: "↑", keyCode: HIDKeyCodes.Up, width: 1, height: 1, modifier: nil),
            Key(label: "↓", keyCode: HIDKeyCodes.Down, width: 1, height: 1, modifier: nil),
            Key(label: "→", keyCode: HIDKeyCodes.Right, width: 1, height: 1, modifier: nil)
        ]
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(Self.keys.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 4) {
                    ForEach(row) { key in
                        Button {
                            handleKeyPress(key)
                        } label: {
                            Text(modifiers.contains(.shift) && key.shiftedLabel != nil ? key.shiftedLabel! : key.label)
                                .frame(width: key.width * 40, height: key.height * 40)
                                .background(key.modifier != nil && modifiers.contains(key.modifier!) ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(key.modifier != nil && modifiers.contains(key.modifier!) ? .white : .primary)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            HStack {
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Keyboard")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleKeyPress(_ key: Key) {
        if let modifier = key.modifier {
            if modifiers.contains(modifier) {
                modifiers.remove(modifier)
            } else {
                modifiers.insert(modifier)
            }
            let modifierFlags = modifiers.reduce(0) { $0 | $1.keyCode }
            reportController.sendModifier(modifier: UInt8(modifierFlags))
        } else {
            // Send key with current modifiers
            let modifierFlags = modifiers.reduce(0) { $0 | $1.keyCode }
            reportController.sendSingleKey(keyCode: key.keyCode, modifier: UInt8(modifierFlags))
        }
    }
}
#endif 