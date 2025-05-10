import Foundation

// Converted from usb_hid_keys.h, see https://gist.github.com/MightyPork/6da26e382a7ad91b5496ee55fdc73db2

enum HIDKeyCodes {
    // Letters
    static let A: UInt8 = 0x04
    static let B: UInt8 = 0x05
    static let C: UInt8 = 0x06
    static let D: UInt8 = 0x07
    static let E: UInt8 = 0x08
    static let F: UInt8 = 0x09
    static let G: UInt8 = 0x0A
    static let H: UInt8 = 0x0B
    static let I: UInt8 = 0x0C
    static let J: UInt8 = 0x0D
    static let K: UInt8 = 0x0E
    static let L: UInt8 = 0x0F
    static let M: UInt8 = 0x10
    static let N: UInt8 = 0x11
    static let O: UInt8 = 0x12
    static let P: UInt8 = 0x13
    static let Q: UInt8 = 0x14
    static let R: UInt8 = 0x15
    static let S: UInt8 = 0x16
    static let T: UInt8 = 0x17
    static let U: UInt8 = 0x18
    static let V: UInt8 = 0x19
    static let W: UInt8 = 0x1A
    static let X: UInt8 = 0x1B
    static let Y: UInt8 = 0x1C
    static let Z: UInt8 = 0x1D
    
    // Numbers
    static let Key1: UInt8 = 0x1E
    static let Key2: UInt8 = 0x1F
    static let Key3: UInt8 = 0x20
    static let Key4: UInt8 = 0x21
    static let Key5: UInt8 = 0x22
    static let Key6: UInt8 = 0x23
    static let Key7: UInt8 = 0x24
    static let Key8: UInt8 = 0x25
    static let Key9: UInt8 = 0x26
    static let Key0: UInt8 = 0x27
    
    // Special keys
    static let Enter: UInt8 = 0x28
    static let Escape: UInt8 = 0x29
    static let Backspace: UInt8 = 0x2A
    static let Tab: UInt8 = 0x2B
    static let Space: UInt8 = 0x2C
    static let Minus: UInt8 = 0x2D
    static let Equal: UInt8 = 0x2E
    static let LeftBracket: UInt8 = 0x2F
    static let RightBracket: UInt8 = 0x30
    static let Backslash: UInt8 = 0x31
    static let Semicolon: UInt8 = 0x33
    static let Apostrophe: UInt8 = 0x34
    static let Grave: UInt8 = 0x35
    static let Comma: UInt8 = 0x36
    static let Dot: UInt8 = 0x37
    static let Slash: UInt8 = 0x38
    
    // Function keys
    static let F1: UInt8 = 0x3A
    static let F2: UInt8 = 0x3B
    static let F3: UInt8 = 0x3C
    static let F4: UInt8 = 0x3D
    static let F5: UInt8 = 0x3E
    static let F6: UInt8 = 0x3F
    static let F7: UInt8 = 0x40
    static let F8: UInt8 = 0x41
    static let F9: UInt8 = 0x42
    static let F10: UInt8 = 0x43
    static let F11: UInt8 = 0x44
    static let F12: UInt8 = 0x45
    
    // Navigation keys
    static let Home: UInt8 = 0x4A
    static let PageUp: UInt8 = 0x4B
    static let Delete: UInt8 = 0x4C
    static let End: UInt8 = 0x4D
    static let PageDown: UInt8 = 0x4E
    static let Right: UInt8 = 0x4F
    static let Left: UInt8 = 0x50
    static let Down: UInt8 = 0x51
    static let Up: UInt8 = 0x52
    
    // Modifier keys
    static let LeftCtrl: UInt8 = 0xE0
    static let LeftShift: UInt8 = 0xE1
    static let LeftAlt: UInt8 = 0xE2
    static let LeftMeta: UInt8 = 0xE3
    static let RightCtrl: UInt8 = 0xE4
    static let RightShift: UInt8 = 0xE5
    static let RightAlt: UInt8 = 0xE6
    static let RightMeta: UInt8 = 0xE7
} 