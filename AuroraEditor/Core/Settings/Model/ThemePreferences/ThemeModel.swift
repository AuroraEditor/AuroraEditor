//
//  ThemeModel.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 31.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

public final class ThemeModel: ObservableObject {
    nonisolated(unsafe) public static let shared: ThemeModel = .init()

    let logger = Logger(subsystem: "com.auroraeditor", category: "Theme Model")

    @Published var selectedAppearance: Int = 0 {
        didSet {
            logger.info("Selected appearance: \(self.selectedAppearance)")
        }
    }

    @Published var selectedTab: Int = 1

    @Published public var themes: [AuroraTheme] = [] {
        didSet {
            saveThemes()
            objectWillChange.send()
        }
    }

    public var defaultTheme: AuroraTheme {
        guard let theme = self.themes.first else {
            fatalError("No themes found!")
        }

        return theme
    }

    @Published public var selectedTheme: AuroraTheme? {
        didSet {
            DispatchQueue.main.async {
                AppPreferencesModel.shared.preferences.theme.selectedTheme = self.selectedTheme?.name
            }
        }
    }

    public var darkThemes: [AuroraTheme] {
        return themes.filter { $0.appearance == .dark }
    }

    public var lightThemes: [AuroraTheme] {
        return themes.filter { $0.appearance == .light }
    }

    public var universalThemes: [AuroraTheme] {
        return themes.filter { $0.appearance == .universal }
    }

    private let filemanager = FileManager.default

    private init() {
        do {
            try loadThemes()
        } catch {
            self.logger.fault("\(error)")
        }
    }

    public func loadThemes() throws {
        themes.removeAll()
        let url = themesURL
        var isDir: ObjCBool = false

        if !filemanager.fileExists(atPath: url.path, isDirectory: &isDir) {
            try filemanager.createDirectory(at: url, withIntermediateDirectories: true)
        }

        try loadBundledThemes()

        let content = try filemanager.contentsOfDirectory(atPath: url.path)
            .filter { $0.hasSuffix(".json") }

        let prefs = AppPreferencesModel.shared.preferences

        try content.forEach { file in
            let fileURL = url.appendingPathComponent(file)
            self.logger.info("Loading \(fileURL)")
            if var theme = ThemeJsonLoader.shared.loadOldAEThemeJson(from: fileURL) ??
                ThemeJsonLoader.shared.loadVscJson(from: fileURL) ??
                ThemeJsonLoader.shared.loadTmThemeXml(from: fileURL) {

                guard let terminalColors = try theme.terminal.allProperties() as? [String: AuroraTheme.Attributes],
                      let editorColors = try theme.editor
                    .allProperties()
                    .filter({ $0.value is AuroraTheme.Attributes }) as? [String: AuroraTheme.Attributes]
                else {
                    fatalError("failed to load terminal and editor colors")
                }

                if let overrides = prefs.theme.overrides[theme.name]?["terminal"] {
                    terminalColors.forEach { (key, _) in
                        if let attributes = overrides[key] {
                            theme.terminal[key] = attributes
                        }
                    }
                }
                if let overrides = prefs.theme.overrides[theme.name]?["editor"] {
                    editorColors.forEach { (key, _) in
                        if let attributes = overrides[key] {
                            theme.editor[key] = attributes
                        }
                    }
                }

                self.themes.append(theme)
            }
        }

        if let existingTheme = self.themes.first(where: {
            $0.name == prefs.theme.selectedTheme }) { self.selectedTheme = existingTheme } else {
                self.selectedTheme = try? getDefaultTheme(with: NSApp.effectiveAppearance.name)
            }
    }

    /// Search for the provided `theme`'s appearance variants.
    /// - Parameter appearance: Search for this appearance variant.
    /// - Returns: Self, if cannot find current theme for appeareance.
    public func getTheme(_ theme: AuroraTheme, with appearance: NSAppearance.Name) -> AuroraTheme {
        let colorSchemeAgnosticThemeName = theme
            .name
            .replacingOccurrences(of: "dark", with: "")
            .replacingOccurrences(of: "light", with: "")
            .lowercased()
        if appearance == .darkAqua || appearance == .vibrantDark {
            return self.darkThemes.first { $0.name.lowercased().contains(colorSchemeAgnosticThemeName) } ?? theme
        } else if appearance == .aqua || appearance == .vibrantLight {
            return self.lightThemes.first { $0.name.lowercased().contains(colorSchemeAgnosticThemeName) } ?? theme
        }
        return theme
    }

    private func getDefaultTheme(with appearance: NSAppearance.Name) throws -> AuroraTheme? {
        enum DefaultTheme {
            static let anyDark = "AuroraEditor-xcode-dark"
            static let anyLight = "AuroraEditor-github-light"
        }
        if appearance == .darkAqua || appearance == .vibrantDark {
            return self.themes.first { $0.name == DefaultTheme.anyDark }
        } else if appearance == .aqua || appearance == .vibrantLight {
            return self.themes.first { $0.name == DefaultTheme.anyLight }
        }
        return nil
    }

    private func loadBundledThemes() throws {
        let bundledThemeNames: [String] = [
            "auroraeditor-xcode-dark.json",
            "auroraeditor-xcode-light.json",
            "auroraeditor-github-dark.json",
            "auroraeditor-github-light.json"
        ]
        for themeName in bundledThemeNames {
            guard let fileName = themeName.components(separatedBy: ".").first,
                  let fileExtension = themeName.components(separatedBy: ".").last,
                  let defaultUrl = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
            else { continue }
            do {
                if !filemanager.fileExists(
                    atPath: themesURL.appendingPathComponent(themeName).relativePath
                ) {
                    try filemanager.copyItem(
                        at: defaultUrl,
                        to: themesURL.appendingPathComponent(themeName)
                    )
                }
            } catch {
                self.logger.fault("\(error)")
                throw error
            }
        }
    }

    public func reset(_ theme: AuroraTheme) {
        AppPreferencesModel.shared.preferences.theme.overrides[theme.name] = [:]
        do {
            try self.loadThemes()
        } catch {
            logger.fault("\(error)")
        }
    }

    public func delete(_ theme: AuroraTheme) {
        let url = themesURL
            .appendingPathComponent(theme.name)
            .appendingPathExtension("json")
        do {
            try filemanager.removeItem(at: url)
            AppPreferencesModel.shared.preferences.theme.overrides.removeValue(forKey: theme.name)
            try self.loadThemes()
        } catch {
            logger.fault("\(error)")
        }
    }

    public func saveThemes() {
        themes.forEach { theme in
            do {
                let themeData = try JSONEncoder().encode(theme)
                let themeURL = themesURL.appendingPathComponent(theme.name).appendingPathExtension("json")
                try themeData.write(to: themeURL)
            } catch {
                self.logger.fault("\(error)")
            }
        }
    }

    public func exportTheme(theme: AuroraTheme, to destinationURL: URL) {
        do {
            let themeData = try JSONEncoder().encode(theme)
            try themeData.write(to: destinationURL)
        } catch {
            self.logger.fault("\(error)")
        }
    }

    public func importTheme(from url: URL) {
        do {
            let themeData = try Data(contentsOf: url)
            if let theme = try? JSONDecoder().decode(AuroraTheme.self, from: themeData) {
                let themeURL = themesURL.appendingPathComponent(theme.name).appendingPathExtension("json")
                try themeData.write(to: themeURL)
                try loadThemes()
            }
        } catch {
            self.logger.fault("\(error)")
        }
    }

    public func fetchCurrentThemes() -> [AuroraTheme] {
        return themes
    }

    internal var themesURL: URL {
        filemanager.auroraEditorBaseURL.appendingPathComponent("Themes", isDirectory: true)
    }
}
