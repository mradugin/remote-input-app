import Carbon.HIToolbox.Events
import AppKit

struct KeyMapping {
    static let map: [Int: UInt8] = [
        // Letters
        kVK_ANSI_A: HIDKeyCodes.A,
        kVK_ANSI_B: HIDKeyCodes.B,
        kVK_ANSI_C: HIDKeyCodes.C,
        kVK_ANSI_D: HIDKeyCodes.D,
        kVK_ANSI_E: HIDKeyCodes.E,
        kVK_ANSI_F: HIDKeyCodes.F,
        kVK_ANSI_G: HIDKeyCodes.G,
        kVK_ANSI_H: HIDKeyCodes.H,
        kVK_ANSI_I: HIDKeyCodes.I,
        kVK_ANSI_J: HIDKeyCodes.J,
        kVK_ANSI_K: HIDKeyCodes.K,
        kVK_ANSI_L: HIDKeyCodes.L,
        kVK_ANSI_M: HIDKeyCodes.M,
        kVK_ANSI_N: HIDKeyCodes.N,
        kVK_ANSI_O: HIDKeyCodes.O,
        kVK_ANSI_P: HIDKeyCodes.P,
        kVK_ANSI_Q: HIDKeyCodes.Q,
        kVK_ANSI_R: HIDKeyCodes.R,
        kVK_ANSI_S: HIDKeyCodes.S,
        kVK_ANSI_T: HIDKeyCodes.T,
        kVK_ANSI_U: HIDKeyCodes.U,
        kVK_ANSI_V: HIDKeyCodes.V,
        kVK_ANSI_W: HIDKeyCodes.W,
        kVK_ANSI_X: HIDKeyCodes.X,
        kVK_ANSI_Y: HIDKeyCodes.Y,
        kVK_ANSI_Z: HIDKeyCodes.Z,
        
        // Numbers
        kVK_ANSI_1: HIDKeyCodes.Key1,
        kVK_ANSI_2: HIDKeyCodes.Key2,
        kVK_ANSI_3: HIDKeyCodes.Key3,
        kVK_ANSI_4: HIDKeyCodes.Key4,
        kVK_ANSI_5: HIDKeyCodes.Key5,
        kVK_ANSI_6: HIDKeyCodes.Key6,
        kVK_ANSI_7: HIDKeyCodes.Key7,
        kVK_ANSI_8: HIDKeyCodes.Key8,
        kVK_ANSI_9: HIDKeyCodes.Key9,
        kVK_ANSI_0: HIDKeyCodes.Key0,
        
        // Special keys
        kVK_Return: HIDKeyCodes.Enter,
        kVK_Escape: HIDKeyCodes.Escape,
        kVK_Delete: HIDKeyCodes.Backspace,
        kVK_Tab: HIDKeyCodes.Tab,
        kVK_Space: HIDKeyCodes.Space,
        kVK_ANSI_Minus: HIDKeyCodes.Minus,
        kVK_ANSI_Equal: HIDKeyCodes.Equal,
        kVK_ANSI_LeftBracket: HIDKeyCodes.LeftBracket,
        kVK_ANSI_RightBracket: HIDKeyCodes.RightBracket,
        kVK_ANSI_Backslash: HIDKeyCodes.Backslash,
        kVK_ANSI_Semicolon: HIDKeyCodes.Semicolon,
        kVK_ANSI_Quote: HIDKeyCodes.Apostrophe,
        kVK_ANSI_Grave: HIDKeyCodes.Grave,
        kVK_ANSI_Comma: HIDKeyCodes.Comma,
        kVK_ANSI_Period: HIDKeyCodes.Dot,
        kVK_ANSI_Slash: HIDKeyCodes.Slash,
        
        // Function keys
        kVK_F1: HIDKeyCodes.F1,
        kVK_F2: HIDKeyCodes.F2,
        kVK_F3: HIDKeyCodes.F3,
        kVK_F4: HIDKeyCodes.F4,
        kVK_F5: HIDKeyCodes.F5,
        kVK_F6: HIDKeyCodes.F6,
        kVK_F7: HIDKeyCodes.F7,
        kVK_F8: HIDKeyCodes.F8,
        kVK_F9: HIDKeyCodes.F9,
        kVK_F10: HIDKeyCodes.F10,
        kVK_F11: HIDKeyCodes.F11,
        kVK_F12: HIDKeyCodes.F12,
        
        // Navigation keys
        kVK_Home: HIDKeyCodes.Home,
        kVK_PageUp: HIDKeyCodes.PageUp,
        kVK_ForwardDelete: HIDKeyCodes.Delete,
        kVK_End: HIDKeyCodes.End,
        kVK_PageDown: HIDKeyCodes.PageDown,
        kVK_RightArrow: HIDKeyCodes.Right,
        kVK_LeftArrow: HIDKeyCodes.Left,
        kVK_DownArrow: HIDKeyCodes.Down,
        kVK_UpArrow: HIDKeyCodes.Up,
        
        // Modifier keys
        kVK_Control: HIDKeyCodes.LeftCtrl,
        kVK_Shift: HIDKeyCodes.LeftShift,
        kVK_Option: HIDKeyCodes.LeftAlt,
        kVK_Command: HIDKeyCodes.LeftMeta,
    ]

    static func getKeyCode(from keyCode: Int) -> UInt8? {
        return map[keyCode]
    }
    
    static func getModifierMask(from flags: NSEvent.ModifierFlags) -> UInt8 {
        var mask: UInt8 = 0
        if flags.contains(.control) {
            mask |= HIDModifierFlags.LeftCtrl
        }
        if flags.contains(.shift) {
            mask |= HIDModifierFlags.LeftShift
        }
        if flags.contains(.option) {
            mask |= HIDModifierFlags.LeftAlt
        }
        if flags.contains(.command) {
            mask |= HIDModifierFlags.LeftMeta
        }
        return mask
    }
} 


