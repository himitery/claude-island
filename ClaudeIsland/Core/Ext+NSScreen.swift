//
//  Ext+NSScreen.swift
//  ClaudeIsland
//
//  Extensions for NSScreen to detect notch and built-in display
//

import AppKit

extension NSScreen {
    var notchSize: CGSize {
        guard safeAreaInsets.top > 0 else {
            let scale = CGFloat(AppSettings.externalMonitorNotchScale)
            if let builtinNotchSize = Self.builtinNotchSize {
                return CGSize(
                    width: builtinNotchSize.width * scale,
                    height: builtinNotchSize.height * scale
                )
            }
            return CGSize(width: 200 * scale, height: 32 * scale)
        }
        return calculateNotchSize()
    }

    private func calculateNotchSize() -> CGSize {
        let notchHeight = safeAreaInsets.top
        let fullWidth = frame.width
        let leftPadding = auxiliaryTopLeftArea?.width ?? 0
        let rightPadding = auxiliaryTopRightArea?.width ?? 0

        guard leftPadding > 0, rightPadding > 0 else {
            return CGSize(width: 180, height: notchHeight)
        }

        let notchWidth = fullWidth - leftPadding - rightPadding + 4
        return CGSize(width: notchWidth, height: notchHeight)
    }

    private static var _builtinNotchSize: CGSize?
    private static var _builtinNotchSizeChecked = false

    static var builtinNotchSize: CGSize? {
        if !_builtinNotchSizeChecked {
            _builtinNotchSizeChecked = true
            if let builtin = screens.first(where: { $0.isBuiltinDisplay && $0.safeAreaInsets.top > 0 }) {
                _builtinNotchSize = builtin.calculateNotchSize()
            }
        }
        return _builtinNotchSize
    }

    static func refreshBuiltinNotchSize() {
        _builtinNotchSizeChecked = false
        _ = builtinNotchSize
    }

    /// Whether this is the built-in display
    var isBuiltinDisplay: Bool {
        guard let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            return false
        }
        return CGDisplayIsBuiltin(screenNumber) != 0
    }

    /// The built-in display (with notch on newer MacBooks)
    static var builtin: NSScreen? {
        if let builtin = screens.first(where: { $0.isBuiltinDisplay }) {
            return builtin
        }
        return NSScreen.main
    }

    /// Whether this screen has a physical notch (camera housing)
    var hasPhysicalNotch: Bool {
        safeAreaInsets.top > 0
    }
}
