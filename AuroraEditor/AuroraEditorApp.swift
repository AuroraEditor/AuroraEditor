//
//  AuroraEditorApp.swift
//  AuroraEditor
//
//  Created by Wesley de Groot on 04/07/2022.
//

import SwiftUI

@main
struct AuroraEditorApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: AuroraEditorDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
