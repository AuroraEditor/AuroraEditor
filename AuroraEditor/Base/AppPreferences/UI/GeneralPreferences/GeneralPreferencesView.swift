//
//  GeneralPreferencesView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `General` preference section
public struct GeneralPreferencesView: View {

    let inputWidth: Double = 160
    let textEditorWidth: Double = 220
    let textEditorHeight: Double = 30

    @StateObject
    var prefs: AppPreferencesModel = .shared

    @State
    var openInAuroraEditor: Bool = true

    public init() {
        guard let defaults = UserDefaults.init(
            suiteName: "com.auroraeditor.shared"
        ) else {
            Log.error("Failed to get/init shared defaults")
            return
        }

        self.openInAuroraEditor = defaults.bool(forKey: "enableOpenInAE")
    }

    public var body: some View {
        PreferencesContent {
            Text("Appearance")
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
                }
                Group {
                    menuItemMode
                        .padding(.vertical, 5)
                }
            }

            GroupBox {
                reopenBehaviorSection
                    .padding(.vertical, 5)
                Divider()
                dialogWarningsSection
                    .padding(.vertical, 5)
            }
            .padding(.bottom)

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

            Text("Inspector")
                .fontWeight(.bold)
                .padding(.horizontal)

            GroupBox {
                keepInspectorWindowOpen
            }
            .padding(.bottom)

            Text("Other")
                .fontWeight(.bold)
                .padding(.horizontal)

            GroupBox {
                openInAuroraEditorToggle
                    .padding(.vertical, 5)
                Divider()
                shellCommandSection
                    .padding(.vertical, 5)
            }
        }
    }
}
