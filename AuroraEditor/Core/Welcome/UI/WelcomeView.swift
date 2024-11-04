//
//  WelcomeView.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import AppKit
import Foundation
import Version_Control

// The main window when opening Aurora Editor when there
// is no project to open. A user can open a project from
// directory, create one or clone one from their desired
// git provider and can drag and drop a file or a folder
public struct WelcomeView: View {
    /// Shell client
    let shellClient: ShellClient

    /// Open document closure
    let openDocument: (URL?, @escaping () -> Void) -> Void

    /// New document closure
    let newDocument: () -> Void

    /// Dismiss window closure
    let dismissWindow: () -> Void

    /// Color scheme
    @Environment(\.colorScheme)
    var colorScheme

    /// Show git clone
    @State
    var showGitClone = false

    /// Repo path
    @State
    private var repoPath = "~/"

    /// Is hovering
    @State
    var isHovering: Bool = false

    /// Is hovering close
    @State
    var isHoveringClose: Bool = false

    /// Initialize a new WelcomeView
    /// 
    /// - Parameter shellClient: shell client
    /// - Parameter openDocument: open document closure
    /// - Parameter newDocument: new document closure
    /// - Parameter dismissWindow: dismiss window closure
    /// 
    /// - Returns: a new WelcomeView
    init(shellClient: ShellClient,
         openDocument: @escaping (URL?, @escaping () -> Void) -> Void,
         newDocument: @escaping () -> Void,
         dismissWindow: @escaping () -> Void) {
        self.shellClient = shellClient
        self.openDocument = openDocument
        self.newDocument = newDocument
        self.dismissWindow = dismissWindow
    }

    /// Application preferences
    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    /// The view body.
    public var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 8) {
                Spacer().frame(height: 12)
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 128, height: 128)
                    .accessibilityLabel(Text("Aura Editor Icon"))
                Text("Welcome to Aurora")
                    .font(.system(size: 38))
                Text("Version \(appVersion) (\(appBuild))")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))
                    .onHover { inside in
                        if inside {
                            NSCursor.pointingHand.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
                    .onTapGesture {
                        copyInformation()
                    }
                    .accessibilityAddTraits(.isButton)

                Spacer().frame(height: 20)
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        WelcomeActionView(
                            iconName: "plus.square",
                            title: "Create a new file",
                            subtitle: "Create a new file"
                        )
                        .onTapGesture {
                            newDocument()
                            dismissWindow()
                        }
                        .accessibilityAddTraits(.isButton)

                        WelcomeActionView(
                            iconName: "plus.square.on.square",
                            title: "Clone an exisiting project",
                            subtitle: gitDisabledText()
                        )
                        .onTapGesture {
                            showGitClone = true
                        }
                        .accessibilityAddTraits(.isButton)
                        .disabled(!prefs.sourceControlActive())

                        WelcomeActionView(
                            iconName: "folder",
                            title: "Open a file or folder",
                            subtitle: "Open an existing file or folder on your Mac"
                        )
                        .onTapGesture {
                            openDocument(nil, dismissWindow)
                        }
                        .accessibilityAddTraits(.isButton)

                        WelcomeActionView(
                            iconName: "cursorarrow.and.square.on.square.dashed",
                            title: "Drag and drop",
                            subtitle: "Open an existing file or folder by drag and dropping it"
                        )
                    }
                }
                Spacer()
            }
            .frame(width: 384)
            .padding(.top, 20)
            .padding(.horizontal, 56)
            .padding(.bottom, 16)
            .background(Color(colorScheme == .dark ? NSColor.windowBackgroundColor : .white))
            .onHover { isHovering in
                self.isHovering = isHovering
            }
            .onDrop(of: ["public.file-url"], isTargeted: nil, perform: { itemProvider in
                if let item = itemProvider.first {
                    _ = item.loadObject(ofClass: URL.self) { (url, _) in
                        if let url = url {
                            openDocument(url, dismissWindow)
                        }
                    }
                }
                return true
            })

            if isHovering {
                HStack(alignment: .center) {
                    dismissButton
                    Spacer()
                }
                .padding(13)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
            }
            if isHovering {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Toggle("Show this window when Aurora launches", isOn: .init(get: {
                            prefs.preferences.general.reopenBehavior == .welcome
                        }, set: { new in
                            prefs.preferences.general.reopenBehavior = new ? .welcome : .openPanel
                        }))
                        .toggleStyle(.checkbox)
                        Spacer()
                    }
                }
                .onHover { isHovering in
                    self.isHovering = isHovering
                }
                .padding(.horizontal, 56)
                .padding(.bottom, 16)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.25)))
            }
        }
        .sheet(isPresented: $showGitClone) {
            GitCloneView(
                shellClient: shellClient,
                isPresented: $showGitClone,
                repoPath: $repoPath
            )
        }
    }

    /// Git disabled text
    /// 
    /// - Returns: a string
    private func gitDisabledText() -> String {
        if prefs.sourceControlActive() {
            return "Start working on something from a Git repository"
        } else {
            return "Source Control is currently disabled, enable it in settings"
        }
    }

    /// Dismis button
    private var dismissButton: some View {
        Button(
            action: dismissWindow,
            label: {
                Circle()
                    .fill(isHoveringClose ? .secondary : Color(.clear))
                    .frame(width: 13, height: 13)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 8.5, weight: .heavy, design: .rounded))
                            .foregroundColor(isHoveringClose ? Color(NSColor.windowBackgroundColor) : .secondary)
                    )
            }
        )
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(Text("Close"))
        .onHover { hover in
            isHoveringClose = hover
            isHovering = hover // Fix for macOS 15+
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            shellClient: .live(),
            openDocument: { _, _  in },
            newDocument: {},
            dismissWindow: {}
        )
        .frame(width: 800, height: 460)
    }
}
