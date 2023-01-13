//
//  EditableListView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2023/01/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Combine

struct EditableListView: NSViewControllerRepresentable {

    @StateObject
    var prefs: AppPreferencesModel = .shared

    func makeNSViewController(context: Context) -> EditableListViewController {
        let controller = EditableListViewController()
        return controller
    }

    func updateNSViewController(_ nsViewController: EditableListViewController, context: Context) {
        nsViewController.rowHeight = prefs.preferences.general.projectNavigatorSize.rowHeight
        return
    }
}
