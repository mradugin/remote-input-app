import Carbon.HIToolbox.Events
import AppKit

struct KeyMapping {
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

    // ASCII to HID key code mapping
    static let asciiMap: [UInt8: UInt8] = [
        // Letters
        0x41: HIDKeyCodes.A, 0x42: HIDKeyCodes.B, 0x43: HIDKeyCodes.C, 0x44: HIDKeyCodes.D,
        0x45: HIDKeyCodes.E, 0x46: HIDKeyCodes.F, 0x47: HIDKeyCodes.G, 0x48: HIDKeyCodes.H,
        0x49: HIDKeyCodes.I, 0x4A: HIDKeyCodes.J, 0x4B: HIDKeyCodes.K, 0x4C: HIDKeyCodes.L,
        0x4D: HIDKeyCodes.M, 0x4E: HIDKeyCodes.N, 0x4F: HIDKeyCodes.O, 0x50: HIDKeyCodes.P,
        0x51: HIDKeyCodes.Q, 0x52: HIDKeyCodes.R, 0x53: HIDKeyCodes.S, 0x54: HIDKeyCodes.T,
        0x55: HIDKeyCodes.U, 0x56: HIDKeyCodes.V, 0x57: HIDKeyCodes.W, 0x58: HIDKeyCodes.X,
        0x59: HIDKeyCodes.Y, 0x5A: HIDKeyCodes.Z,
        
        // Numbers
        0x30: HIDKeyCodes.Key0, 0x31: HIDKeyCodes.Key1, 0x32: HIDKeyCodes.Key2,
        0x33: HIDKeyCodes.Key3, 0x34: HIDKeyCodes.Key4, 0x35: HIDKeyCodes.Key5,
        0x36: HIDKeyCodes.Key6, 0x37: HIDKeyCodes.Key7, 0x38: HIDKeyCodes.Key8,
        0x39: HIDKeyCodes.Key9,
        
        // Special characters
        0x20: HIDKeyCodes.Space,
        0x2D: HIDKeyCodes.Minus,
        0x3D: HIDKeyCodes.Equal,
        0x5B: HIDKeyCodes.LeftBracket,
        0x5D: HIDKeyCodes.RightBracket,
        0x5C: HIDKeyCodes.Backslash,
        0x3B: HIDKeyCodes.Semicolon,
        0x27: HIDKeyCodes.Apostrophe,
        0x60: HIDKeyCodes.Grave,
        0x2C: HIDKeyCodes.Comma,
        0x2E: HIDKeyCodes.Dot,
        0x2F: HIDKeyCodes.Slash,
        
        // Control characters
        0x0A: HIDKeyCodes.Enter,  // Line feed
        0x0D: HIDKeyCodes.Enter,  // Carriage return
        0x09: HIDKeyCodes.Tab     // Tab
    ]

    static func getKeyCode(fromEvent keyCode: Int) -> UInt8? {
        return keyCodeMap[keyCode]
    }
    
    static func getKeyCode(formAscii char: UInt8) -> UInt8? {
        return asciiMap[char]
    }
    

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
} 


