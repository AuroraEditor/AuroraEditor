//
//  EditableList.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct EditableList<Element: Identifiable, Content: View>: View {
    @Binding
    var data: [Element]

    var content: (Binding<Element>) -> Content

    init(_ data: Binding<[Element]>,
         content: @escaping (Binding<Element>) -> Content) {
        self._data = data
        self.content = content
    }

    var body: some View {
        List {
            ForEach($data, content: content)
                .onMove { indexSet, offset in
                    data.move(fromOffsets: indexSet, toOffset: offset)
                }
                .onDelete { indexSet in
                    data.remove(atOffsets: indexSet)
                }
        }
    }
}
