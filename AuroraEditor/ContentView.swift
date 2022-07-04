//
//  ContentView.swift
//  AuroraEditor
//
//  Created by Wesley de Groot on 04/07/2022.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: AuroraEditorDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(AuroraEditorDocument()))
    }
}
