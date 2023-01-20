//
//  FileInspectorModel.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/17.
//

import SwiftUI

public final class FileInspectorModel: ObservableObject {

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    let fileManager = FileManager.default

    @Published
    var fileTypeSelection: LanguageType.ID = ""

    @Published
    var fileURL: String = ""

    @Published
    private var oldFileName: String = ""

    @Published
    var fileName: String = ""

    @Published
    var locationSelection: FileLocation.ID = "relative_group"
    @Published
    var textEncodingSelection: TextEncoding.ID = "utf8"
    @Published
    var lineEndingsSelection: LineEndings.ID = "macos"
    @Published
    var indentUsingSelection: IndentUsing.ID = "spaces"

    @Published
    var languageTypeAuroraEditor = FileTypeList().languageTypeAuroraEditor
    @Published
    var languageTypeObjCList = FileTypeList().languageTypeObjCList
    @Published
    var sourcecodeCList = FileTypeList().sourcecodeCList
    @Published
    var sourcecodeCPlusList = FileTypeList().sourcecodeCPlusList
    @Published
    var sourcecodeSwiftList = FileTypeList().sourcecodeSwiftList
    @Published
    var sourcecodeAssemblyList = FileTypeList().sourcecodeAssemblyList
    @Published
    var sourcecodeScriptList = FileTypeList().sourcecodeScriptList
    @Published
    var sourcecodeVariousList = FileTypeList().sourcecodeVariousList
    @Published
    var propertyList = FileTypeList().propertyList
    @Published
    var shellList = FileTypeList().shellList
    @Published
    var machOList = FileTypeList().machOList
    @Published
    var textList = FileTypeList().textList
    @Published
    var audioList = FileTypeList().audioList
    @Published
    var imageList = FileTypeList().imageList
    @Published
    var videoList = FileTypeList().videoList
    @Published
    var archiveList = FileTypeList().archiveList
    @Published
    var otherList = FileTypeList().otherList

    @Published
    var locationList = [FileLocation(name: "Absolute Path", id: "absolute"),
                        FileLocation(name: "Relative to Group", id: "relative_group"),
                        FileLocation(name: "Relative to Project", id: "relative_project"),
                        FileLocation(name: "Relative to Developer Directory", id: "relative_developer_dir"),
                        FileLocation(name: "Relative to Build Projects", id: "relative_build_projects"),
                        FileLocation(name: "Relative to SDK", id: "relative_sdk")]

    @Published
    var textEncodingList = [TextEncoding(name: "Unicode (UTF-8)", id: "utf8"),
                            TextEncoding(name: "Unicode (UTF-16)", id: "utf16"),
                            TextEncoding(name: "Unicode (UTF-16BE)", id: "utf16_be"),
                            TextEncoding(name: "Unicode (UTF-16LE)", id: "utf16_le")]

    @Published
    var lineEndingsList = [LineEndings(name: "macOS / Unix (LF)", id: "macos"),
                           LineEndings(name: "Classic macOS (CR)", id: "classic"),
                           LineEndings(name: "Windows (CRLF)", id: "windows")]

    @Published
    var indentUsingList = [IndentUsing(name: "Spaces", id: "spaces"),
                           IndentUsing(name: "Tabs", id: "tabs")]

    public init(workspaceURL: URL, fileURL: String) {
        self.workspaceURL = workspaceURL
        self.fileURL = fileURL
        self.oldFileName = (fileURL as NSString).lastPathComponent
        self.fileName = (fileURL as NSString).lastPathComponent
        self.fileTypeSelection = (fileURL as NSString).pathExtension
    }
}
