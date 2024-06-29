//
//  GeneralPreferencesView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 30.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// A view that implements the `General` preference section
public struct GeneralPreferencesView: View {
    /// The width of the input fields
    let inputWidth: Double = 160

    /// The width of the text editor fields
    let textEditorWidth: Double = 220

    /// The height of the text editor fields
    let textEditorHeight: Double = 30

    /// App preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    /// Open in Aurora Editor toggle
    @State
    var openInAuroraEditor: Bool = true

    /// Logger
    let logger: Logger

    /// Initializes the general preferences view
    public init() {
        self.logger = Logger(subsystem: "com.auroraeditor", category: "General Preferences View")

        guard let defaults = UserDefaults(
            suiteName: "com.auroraeditor.shared"
        ) else {
            return
        }

        self.openInAuroraEditor = defaults.bool(forKey: "enableOpenInAE")
    }

    /// The view body
    public var body: some View {
        PreferencesContent {
            Text("settings.general.appearance")
                .fontWeight(.bold)
                .padding(.horizontal)

            GroupBox {
                Group {
                    appearanceSection
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    showIssuesSection
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    fileExtensionsSection
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    fileIconStyleSection
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    tabBarStyleSection
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    sidebarStyleSection
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    menuItemMode
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    reopenBehaviorSection
                        .padding(.vertical, 5)
                    Divider()
                }
                Group {
                    dialogWarningsSection
                        .padding(.vertical, 5)
                }
            }
            .padding(.bottom)

            Group {
                Text("Navigator")
                    .fontWeight(.bold)
                    .padding(.horizontal)

                GroupBox {
                    projectNavigatorSizeSection
                        .padding(.vertical, 5)
                    Divider()
                    findNavigatorDetailSection
                        .padding(.vertical, 5)
                    Divider()
                    issueNavigatorDetailSection
                        .padding(.vertical, 5)
                    Divider()
                    revealFileOnFocusChangeToggle
                        .padding(.vertical, 5)
                }
                .padding(.bottom)
            }

            Group {
                Text("Inspector")
                    .fontWeight(.bold)
                    .padding(.horizontal)

                GroupBox {
                    keepInspectorWindowOpen
                }
                .padding(.bottom)
            }

            Group {
                Text("Other")
                    .fontWeight(.bold)
                    .padding(.horizontal)

                GroupBox {
                    openInAuroraEditorToggle
                        .padding(.vertical, 5)
                    Divider()
                    shellCommandSection
                        .padding(.vertical, 5)
                    Divider()
                    preferencesLocation
                        .padding(.vertical, 5)
                    Divider()
                    installPathLocation
                        .padding(.vertical, 5)
                }
                .padding(.bottom)
            }
        }
    }
}
