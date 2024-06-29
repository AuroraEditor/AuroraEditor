//
//  FileInspectorModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/17.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// File inspector model
public final class FileInspectorModel: ObservableObject {

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// File manager
    let fileManager = FileManager.default

    /// File type selection
    @Published
    var fileTypeSelection: LanguageType.ID = ""

    /// File url
    @Published
    var fileURL: String = ""

    /// Old file name
    @Published
    private var oldFileName: String = ""

    /// File name
    @Published
    var fileName: String = ""

    /// File location selection
    @Published
    var locationSelection: FileLocation.ID = "relative_group"

    /// Text encoding selection
    @Published
    var textEncodingSelection: TextEncoding.ID = "utf8"

    /// Line endings selection
    @Published
    var lineEndingsSelection: LineEndings.ID = "macos"

    /// Indent using selection
    @Published
    var indentUsingSelection: IndentUsing.ID = "spaces"

    /// Language items (Aurora Editor project file)
    @Published
    var languageTypeAuroraEditor = FileTypeList().languageTypeAuroraEditor

    /// Language items (Objective-C source file)
    @Published
    var languageTypeObjCList = FileTypeList().languageTypeObjCList

    /// Language items (C source file)
    @Published
    var sourcecodeCList = FileTypeList().sourcecodeCList

    /// Language items (C++ source file)
    @Published
    var sourcecodeCPlusList = FileTypeList().sourcecodeCPlusList

    /// Language items (Swift source file)
    @Published
    var sourcecodeSwiftList = FileTypeList().sourcecodeSwiftList

    /// Language items (Assembly source file)
    @Published
    var sourcecodeAssemblyList = FileTypeList().sourcecodeAssemblyList

    /// Language items (Source code script file)
    @Published
    var sourcecodeScriptList = FileTypeList().sourcecodeScriptList

    /// Language items (Source code various files)
    @Published
    var sourcecodeVariousList = FileTypeList().sourcecodeVariousList

    /// Language items (Property list)
    @Published
    var propertyList = FileTypeList().propertyList

    /// Language items (Shell script)
    @Published
    var shellList = FileTypeList().shellList

    /// Language items (Macj-O binary)
    @Published
    var machOList = FileTypeList().machOList

    /// Language items (Text)
    @Published
    var textList = FileTypeList().textList

    /// Language items (Audio)
    @Published
    var audioList = FileTypeList().audioList

    /// Language items (Image)
    @Published
    var imageList = FileTypeList().imageList

    /// Language items (Video)
    @Published
    var videoList = FileTypeList().videoList

    /// Language items (Archive)
    @Published
    var archiveList = FileTypeList().archiveList

    /// Language items (Other)
    @Published
    var otherList = FileTypeList().otherList

    /// File location list
    @Published
    var locationList = [FileLocation(name: "Absolute Path", id: "absolute"),
                        FileLocation(name: "Relative to Group", id: "relative_group"),
                        FileLocation(name: "Relative to Project", id: "relative_project"),
                        FileLocation(name: "Relative to Developer Directory", id: "relative_developer_dir"),
                        FileLocation(name: "Relative to Build Projects", id: "relative_build_projects"),
                        FileLocation(name: "Relative to SDK", id: "relative_sdk")]

    /// Text encoding list
    @Published
    var textEncodingList = [TextEncoding(name: "Unicode (UTF-8)", id: "utf8"),
                            TextEncoding(name: "Unicode (UTF-16)", id: "utf16"),
                            TextEncoding(name: "Unicode (UTF-16BE)", id: "utf16_be"),
                            TextEncoding(name: "Unicode (UTF-16LE)", id: "utf16_le")]

    /// Line endings list
    @Published
    var lineEndingsList = [LineEndings(name: "macOS / Unix (LF)", id: "macos"),
                           LineEndings(name: "Classic macOS (CR)", id: "classic"),
                           LineEndings(name: "Windows (CRLF)", id: "windows")]

    /// Indent using list
    @Published
    var indentUsingList = [IndentUsing(name: "Spaces", id: "spaces"),
                           IndentUsing(name: "Tabs", id: "tabs")]

    /// Initialize file inspector model
    /// 
    /// - Parameter workspaceURL: The base URL of the workspace
    /// - Parameter fileURL: File URL
    /// 
    /// - Returns: File inspector model
    public init(workspaceURL: URL, fileURL: String) {
        self.workspaceURL = workspaceURL
        self.fileURL = fileURL
        self.oldFileName = (fileURL as NSString).lastPathComponent
        self.fileName = (fileURL as NSString).lastPathComponent
        self.fileTypeSelection = (fileURL as NSString).pathExtension
    }
}
