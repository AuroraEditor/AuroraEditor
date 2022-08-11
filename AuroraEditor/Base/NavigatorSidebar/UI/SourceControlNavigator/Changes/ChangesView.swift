//
//  ChangesView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

// TODO: Convert to OutlineView @NanashiLi
struct ChangesView: View {

    @ObservedObject
    var workspace: WorkspaceDocument

    var body: some View {
        SourceControlView(workspace: workspace)
    }
}
