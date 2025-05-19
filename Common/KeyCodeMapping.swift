#if os(macOS)
import Carbon.HIToolbox.Events
import AppKit
#endif

struct KeyMapping {
    #if os(macOS)
    static let keyCodeMap: [Int: UInt8] = [
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
    #else
    static let keyCodeMap: [Int: UInt8] = [:]
    #endif
    // ASCII to HID key code mapping with modifiers
    static let asciiMap: [UInt8: (keyCode: UInt8, modifier: UInt8)] = [
        // Letters (uppercase need shift)
        0x41: (HIDKeyCodes.A, HIDModifierFlags.LeftShift), 0x42: (HIDKeyCodes.B, HIDModifierFlags.LeftShift),
        0x43: (HIDKeyCodes.C, HIDModifierFlags.LeftShift), 0x44: (HIDKeyCodes.D, HIDModifierFlags.LeftShift),
        0x45: (HIDKeyCodes.E, HIDModifierFlags.LeftShift), 0x46: (HIDKeyCodes.F, HIDModifierFlags.LeftShift),
        0x47: (HIDKeyCodes.G, HIDModifierFlags.LeftShift), 0x48: (HIDKeyCodes.H, HIDModifierFlags.LeftShift),
        0x49: (HIDKeyCodes.I, HIDModifierFlags.LeftShift), 0x4A: (HIDKeyCodes.J, HIDModifierFlags.LeftShift),
        0x4B: (HIDKeyCodes.K, HIDModifierFlags.LeftShift), 0x4C: (HIDKeyCodes.L, HIDModifierFlags.LeftShift),
        0x4D: (HIDKeyCodes.M, HIDModifierFlags.LeftShift), 0x4E: (HIDKeyCodes.N, HIDModifierFlags.LeftShift),
        0x4F: (HIDKeyCodes.O, HIDModifierFlags.LeftShift), 0x50: (HIDKeyCodes.P, HIDModifierFlags.LeftShift),
        0x51: (HIDKeyCodes.Q, HIDModifierFlags.LeftShift), 0x52: (HIDKeyCodes.R, HIDModifierFlags.LeftShift),
        0x53: (HIDKeyCodes.S, HIDModifierFlags.LeftShift), 0x54: (HIDKeyCodes.T, HIDModifierFlags.LeftShift),
        0x55: (HIDKeyCodes.U, HIDModifierFlags.LeftShift), 0x56: (HIDKeyCodes.V, HIDModifierFlags.LeftShift),
        0x57: (HIDKeyCodes.W, HIDModifierFlags.LeftShift), 0x58: (HIDKeyCodes.X, HIDModifierFlags.LeftShift),
        0x59: (HIDKeyCodes.Y, HIDModifierFlags.LeftShift), 0x5A: (HIDKeyCodes.Z, HIDModifierFlags.LeftShift),
        
        // Lowercase letters (no shift)
        0x61: (HIDKeyCodes.A, 0), 0x62: (HIDKeyCodes.B, 0),
        0x63: (HIDKeyCodes.C, 0), 0x64: (HIDKeyCodes.D, 0),
        0x65: (HIDKeyCodes.E, 0), 0x66: (HIDKeyCodes.F, 0),
        0x67: (HIDKeyCodes.G, 0), 0x68: (HIDKeyCodes.H, 0),
        0x69: (HIDKeyCodes.I, 0), 0x6A: (HIDKeyCodes.J, 0),
        0x6B: (HIDKeyCodes.K, 0), 0x6C: (HIDKeyCodes.L, 0),
        0x6D: (HIDKeyCodes.M, 0), 0x6E: (HIDKeyCodes.N, 0),
        0x6F: (HIDKeyCodes.O, 0), 0x70: (HIDKeyCodes.P, 0),
        0x71: (HIDKeyCodes.Q, 0), 0x72: (HIDKeyCodes.R, 0),
        0x73: (HIDKeyCodes.S, 0), 0x74: (HIDKeyCodes.T, 0),
        0x75: (HIDKeyCodes.U, 0), 0x76: (HIDKeyCodes.V, 0),
        0x77: (HIDKeyCodes.W, 0), 0x78: (HIDKeyCodes.X, 0),
        0x79: (HIDKeyCodes.Y, 0), 0x7A: (HIDKeyCodes.Z, 0),
        
        // Numbers (no shift)
        0x30: (HIDKeyCodes.Key0, 0), 0x31: (HIDKeyCodes.Key1, 0),
        0x32: (HIDKeyCodes.Key2, 0), 0x33: (HIDKeyCodes.Key3, 0),
        0x34: (HIDKeyCodes.Key4, 0), 0x35: (HIDKeyCodes.Key5, 0),
        0x36: (HIDKeyCodes.Key6, 0), 0x37: (HIDKeyCodes.Key7, 0),
        0x38: (HIDKeyCodes.Key8, 0), 0x39: (HIDKeyCodes.Key9, 0),
        
        // Special characters (no shift)
        0x20: (HIDKeyCodes.Space, 0),
        0x2D: (HIDKeyCodes.Minus, 0),
        0x3D: (HIDKeyCodes.Equal, 0),
        0x5B: (HIDKeyCodes.LeftBracket, 0),
        0x5D: (HIDKeyCodes.RightBracket, 0),
        0x5C: (HIDKeyCodes.Backslash, 0),
        0x3B: (HIDKeyCodes.Semicolon, 0),
        0x27: (HIDKeyCodes.Apostrophe, 0),
        0x60: (HIDKeyCodes.Grave, 0),
        0x2C: (HIDKeyCodes.Comma, 0),
        0x2E: (HIDKeyCodes.Dot, 0),
        0x2F: (HIDKeyCodes.Slash, 0),
        
        // Shifted special characters
        0x21: (HIDKeyCodes.Key1, HIDModifierFlags.LeftShift),      // !
        0x22: (HIDKeyCodes.Apostrophe, HIDModifierFlags.LeftShift), // "
        0x23: (HIDKeyCodes.Key3, HIDModifierFlags.LeftShift),      // #
        0x24: (HIDKeyCodes.Key4, HIDModifierFlags.LeftShift),      // $
        0x25: (HIDKeyCodes.Key5, HIDModifierFlags.LeftShift),      // %
        0x26: (HIDKeyCodes.Key7, HIDModifierFlags.LeftShift),      // &
        0x28: (HIDKeyCodes.Key9, HIDModifierFlags.LeftShift),      // (
        0x29: (HIDKeyCodes.Key0, HIDModifierFlags.LeftShift),      // )
        0x2A: (HIDKeyCodes.Key8, HIDModifierFlags.LeftShift),      // *
        0x2B: (HIDKeyCodes.Equal, HIDModifierFlags.LeftShift),     // +
        0x3A: (HIDKeyCodes.Semicolon, HIDModifierFlags.LeftShift), // :
        0x3C: (HIDKeyCodes.Comma, HIDModifierFlags.LeftShift),     // <
        0x3E: (HIDKeyCodes.Dot, HIDModifierFlags.LeftShift),       // >
        0x3F: (HIDKeyCodes.Slash, HIDModifierFlags.LeftShift),     // ?
        0x40: (HIDKeyCodes.Key2, HIDModifierFlags.LeftShift),      // @
        0x5E: (HIDKeyCodes.Key6, HIDModifierFlags.LeftShift),      // ^
        0x5F: (HIDKeyCodes.Minus, HIDModifierFlags.LeftShift),     // _
        0x7B: (HIDKeyCodes.LeftBracket, HIDModifierFlags.LeftShift), // {
        0x7C: (HIDKeyCodes.Backslash, HIDModifierFlags.LeftShift),   // |
        0x7D: (HIDKeyCodes.RightBracket, HIDModifierFlags.LeftShift), // }
        0x7E: (HIDKeyCodes.Grave, HIDModifierFlags.LeftShift),      // ~
        
        // Control characters
        0x0A: (HIDKeyCodes.Enter, 0),  // Line feed
        0x09: (HIDKeyCodes.Tab, 0)     // Tab
    ]

    static func getKeyCode(fromEvent keyCode: Int) -> UInt8? {
        return keyCodeMap[keyCode]
    }
    
    static func getKeyCode(formAscii char: UInt8) -> (keyCode: UInt8, modifier: UInt8)? {
        return asciiMap[char]
    }
    
    #if os(macOS)
    static func getModifierMask(from flags: NSEvent.ModifierFlags) -> UInt8 {
        let rawValue = flags.rawValue
        var mask: UInt8 = 0
        if rawValue & UInt(NX_DEVICELSHIFTKEYMASK) != 0 {
            mask |= HIDModifierFlags.LeftShift
        }
        if rawValue & UInt(NX_DEVICERSHIFTKEYMASK) != 0 {
            mask |= HIDModifierFlags.RightShift
        }
        if rawValue & UInt(NX_DEVICELALTKEYMASK) != 0 {
            mask |= HIDModifierFlags.LeftAlt
        }
        if rawValue & UInt(NX_DEVICERALTKEYMASK) != 0 {
            mask |= HIDModifierFlags.RightAlt
        }
        if rawValue & UInt(NX_DEVICELCTLKEYMASK) != 0 {
            mask |= HIDModifierFlags.LeftCtrl
        }
        if rawValue & UInt(NX_DEVICERCTLKEYMASK) != 0 {
            mask |= HIDModifierFlags.RightCtrl
        }   
        if rawValue & UInt(NX_DEVICELCMDKEYMASK) != 0 {
            mask |= HIDModifierFlags.LeftMeta
        }
        if rawValue & UInt(NX_DEVICERCMDKEYMASK) != 0 {
            mask |= HIDModifierFlags.RightMeta
        }
        return mask
    }
    #endif
} 


