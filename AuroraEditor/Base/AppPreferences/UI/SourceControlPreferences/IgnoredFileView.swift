//
//  IgnoredFileView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct IgnoredFileView: View {

    @Binding
    var ignoredFile: IgnoredFiles

    var body: some View {
        Text(ignoredFile.name)
    }
}
