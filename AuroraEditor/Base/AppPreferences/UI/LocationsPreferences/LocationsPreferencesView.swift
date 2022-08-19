//
//  LocationsPreferencesView.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI

/// A view that implements the `Locations` preference section
public struct LocationsPreferencesView: View {

    public init() {}

    public var body: some View {
        PreferencesContent {
            GroupBox {
                VStack {
                    HStack {
                        Text("Preferences Location")

                        Spacer()

                        HStack {
                            Text(AppPreferencesModel.shared.baseURL.path)
                                .foregroundColor(.secondary)
                            Button {
                                NSWorkspace.shared.selectFile(
                                    nil,
                                    inFileViewerRootedAtPath: AppPreferencesModel.shared.baseURL.path
                                )
                            } label: {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 5)
                    .padding(.horizontal)

                    Divider()

                    HStack {
                        Text("Themes Location")

                        Spacer()

                        HStack {
                            Text(ThemeModel.shared.themesURL.path)
                                .foregroundColor(.secondary)
                            Button {
                                NSWorkspace.shared.selectFile(
                                    nil,
                                    inFileViewerRootedAtPath: ThemeModel.shared.themesURL.path)
                            } label: {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 5)
                    .padding(.horizontal)
                }
            }
        }
    }
}
