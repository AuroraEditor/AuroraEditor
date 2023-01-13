//
//  EditableListDataSource.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension EditableListViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return prefs.preferences.general.hiddenFilesAndFolders.count
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return content[index]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }
}
