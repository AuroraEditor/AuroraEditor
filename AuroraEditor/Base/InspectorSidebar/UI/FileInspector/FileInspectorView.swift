//
//  FileInspectorView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

// swiftlint:disable:next type_body_length
struct FileInspectorView: View {

    @ObservedObject
    private var inspectorModel: FileInspectorModel

    let fileManager = FileManager.default

    @State
    private var identityTypeHover: Bool = false

    @State
    private var hideidentityType: Bool = true

    @State
    private var textSettingsHover: Bool = false

    @State
    private var hideTextSettings: Bool = true

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL, fileURL: String) {
        self.inspectorModel = .init(workspaceURL: workspaceURL, fileURL: fileURL)
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Text("Identity and Type")
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                        .font(.system(size: 13))

                    Spacer()

                    if identityTypeHover {
                        Text(hideidentityType ? "Hide" : "Show")
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .onTapGesture {
                                hideidentityType.toggle()
                            }
                    }
                }

                if hideidentityType {
                    VStack {
                        VStack(alignment: .trailing) {
                            HStack {
                                Text("Name")
                                    .foregroundColor(.primary)
                                    .fontWeight(.regular)
                                    .font(.system(size: 10))
                                TextField("", text: $inspectorModel.fileName)
                                    .font(.system(size: 11))
                                    .frame(maxWidth: 150)
                                    .onSubmit {
                                        changeFileName(newFileName: inspectorModel.fileName)
                                    }
                            }

                            HStack {
                                Text("Type")
                                    .foregroundColor(.primary)
                                    .fontWeight(.regular)
                                    .font(.system(size: 10))
                                fileType
                            }

                            Divider()
                        }

                        VStack(alignment: .trailing) {
                            HStack(alignment: .top) {
                                Text("Location")
                                    .foregroundColor(.primary)
                                    .fontWeight(.regular)
                                    .font(.system(size: 10))

                                VStack {
                                    location
                                    HStack {
                                        Text(inspectorModel.fileName)
                                            .font(.system(size: 11))

                                        Spacer()

                                        Image(systemName: "folder.fill")
                                            .resizable()
                                            .foregroundColor(.secondary)
                                            .frame(width: 13, height: 11)
                                    }
                                }.frame(maxWidth: 150)
                            }
                            .padding(.top, 1)

                            HStack(alignment: .top) {
                                Text("Full Path")
                                    .foregroundColor(.primary)
                                    .fontWeight(.regular)
                                    .font(.system(size: 10))

                                HStack(alignment: .bottom) {
                                    Text(inspectorModel.fileURL)
                                        .foregroundColor(.primary)
                                        .fontWeight(.regular)
                                        .font(.system(size: 10))
                                        .lineLimit(4)

                                    Image(systemName: "arrow.forward.circle.fill")
                                        .resizable()
                                        .foregroundColor(.secondary)
                                        .frame(width: 11, height: 11)
                                        .onTapGesture {
                                            guard let url = URL(string: "file://\(inspectorModel.fileURL)") else {
                                                Log.error("Failed to decode")
                                                return
                                            }

                                            NSWorkspace.shared.activateFileViewerSelecting([url])
                                        }

                                }
                                .frame(maxWidth: 150, alignment: .leading)
                            }
                            .padding(.top, -5)

                            Divider()
                        }
                    }
                }
            }
            .onHover { hover in
                identityTypeHover = hover
            }

            if !hideidentityType {
                Divider()
            }

            VStack(alignment: .leading) {
                HStack {
                    Text("Text Settings")
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)

                    Spacer()

                    if textSettingsHover {
                        Text(hideTextSettings ? "Hide" : "Show")
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .onTapGesture {
                                hideTextSettings.toggle()
                            }
                    }
                }

                if hideTextSettings {
                    VStack(alignment: .trailing) {
                        HStack {
                            Text("Text Encoding")
                                .foregroundColor(.primary)
                                .fontWeight(.regular)
                                .font(.system(size: 10))
                            textEncoding
                        }

                        HStack {
                            Text("Line Endings")
                                .foregroundColor(.primary)
                                .fontWeight(.regular)
                                .font(.system(size: 10))
                            lineEndings
                        }
                        .padding(.top, 4)

                        Divider()

                        HStack {
                            Text("Indent Using")
                                .foregroundColor(.primary)
                                .fontWeight(.regular)
                                .font(.system(size: 10))
                            indentUsing
                        }
                        .padding(.top, 1)
                    }
                }
            }
            .onHover { hovering in
                textSettingsHover = hovering
            }

            Divider()

        }
        .frame(minWidth: 250, maxWidth: .infinity)
        .padding(5)
    }

    private var fileType: some View {
        Picker("", selection: $inspectorModel.fileTypeSelection) {
            Group {
                Section(header: Text("Auroraeditor")) {
                    ForEach(inspectorModel.languageTypeAuroraEditor) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode Objective-C")) {
                    ForEach(inspectorModel.languageTypeObjCList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode C")) {
                    ForEach(inspectorModel.sourcecodeCList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode C++")) {
                    ForEach(inspectorModel.sourcecodeCPlusList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode Swift")) {
                    ForEach(inspectorModel.sourcecodeSwiftList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Sourcecode Assembly")) {
                    ForEach(inspectorModel.sourcecodeAssemblyList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
            }
            Group {
                Section(header: Text("Sourcecode Script")) {
                    ForEach(inspectorModel.sourcecodeScriptList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Property List / XML")) {
                    ForEach(inspectorModel.propertyList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Shell Script")) {
                    ForEach(inspectorModel.shellList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Mach-O")) {
                    ForEach(inspectorModel.machOList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Text")) {
                    ForEach(inspectorModel.textList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
            }
            Group {
                Section(header: Text("Audio")) {
                    ForEach(inspectorModel.audioList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Image")) {
                    ForEach(inspectorModel.imageList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Video")) {
                    ForEach(inspectorModel.videoList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Archive")) {
                    ForEach(inspectorModel.archiveList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
                Section(header: Text("Other")) {
                    ForEach(inspectorModel.otherList) {
                        Text($0.name)
                            .font(.system(size: 11))
                    }
                }
            }
        }
        .labelsHidden()
        .frame(maxWidth: 150, maxHeight: 15)
    }

    private var location: some View {
        Picker("", selection: $inspectorModel.locationSelection) {
            ForEach(inspectorModel.locationList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
        .frame(maxWidth: 150, maxHeight: 12)
    }

    private var textEncoding: some View {
        Picker("", selection: $inspectorModel.textEncodingSelection) {
            ForEach(inspectorModel.textEncodingList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
        .frame(maxWidth: 150, maxHeight: 12)
    }

    private var lineEndings: some View {
        Picker("", selection: $inspectorModel.lineEndingsSelection) {
            ForEach(inspectorModel.lineEndingsList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
        .frame(maxWidth: 150, maxHeight: 12)
    }

    private var indentUsing: some View {
        Picker("", selection: $inspectorModel.indentUsingSelection) {
            ForEach(inspectorModel.indentUsingList) {
                Text($0.name)
                    .font(.system(size: 11))
            }
        }
        .labelsHidden()
        .frame(maxWidth: 150, maxHeight: 12)
    }

    private func changeFileName(newFileName: String) {
        let fileName = "\((inspectorModel.fileURL as NSString).deletingLastPathComponent)/\(newFileName)"
        do {
            try fileManager.moveItem(atPath: inspectorModel.fileURL,
                                     toPath: fileName)
        } catch let error as NSError {
            Log.error("Ooops! Something went wrong: \(error)")
            Log.info(fileName)
        }
    }
}
