//
//  AuroraMessageBox.swift
//  AuroraEditor
//
//  Created by Wesley de Groot on 20/08/2022.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// Show a message box
/// - Parameters:
///   - type: Style/Type
///   - message: Message
/// - Returns: true on ok, false on cancel
@discardableResult
func auroraMessageBox(type: NSAlert.Style, message: String) -> Bool {
    let alert: NSAlert = NSAlert()
    alert.messageText = "Aurora Editor"
    alert.informativeText = message
    alert.alertStyle = type
    alert.addButton(
        withTitle: NSLocalizedString("Ok", comment: "Ok")
    )
    if type != .critical {
        alert.addButton(
            withTitle: NSLocalizedString("Cancel", comment: "Cancel")
        )
    }
    let res = alert.runModal()
    if res == NSApplication.ModalResponse.alertFirstButtonReturn {
        return true
    }
    return false
}
