//
//  FileTypeList.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/04/18.
//

import Foundation

/// A collection of file types and their associated extensions,
///  which can be selected in the inspector to override default values
final class FileTypeList {

    var languageTypeObjCList = [
        LanguageType(name: "Objective-C Preprocessed Source"),
        LanguageType(name: "Objective-C Source"),
        LanguageType(name: "Objective-C++ Preprocessed Source"),
        LanguageType(name: "Objective-C++ Source")
    ]

    var sourcecodeCList = [
        LanguageType(name: "C Header"),
        LanguageType(name: "C Preprocessed Source"),
        LanguageType(name: "C Source")
    ]

    var sourcecodeCPlusList = [
        LanguageType(name: "C++ Header"),
        LanguageType(name: "C++ Preprocessed Source"),
        LanguageType(name: "C++ Source")]

    var sourcecodeSwiftList = [LanguageType(name: "Swift Source")
    ]

    var sourcecodeAssemblyList = [
        LanguageType(name: "Assembly"),
        LanguageType(name: "LLVM Assembly"),
        LanguageType(name: "NASM Assembly"),
        LanguageType(name: "PPC Assembly")
    ]

    var sourcecodeScriptList = [
        LanguageType(name: "AppleScript Uncompiled Source"),
        LanguageType(name: "JavaScript Source"),
        LanguageType(name: "PHP Script"),
        LanguageType(name: "Perl Script"),
        LanguageType(name: "Python Script"),
        LanguageType(name: "Ruby Script")]

    var sourcecodeVariousList = [LanguageType(name: "Ada Source"),
                                 LanguageType(name: "CLIPS Source"),
                                 LanguageType(name: "DTrace Source"),
                                 LanguageType(name: "Fortran 77 Source"),
                                 LanguageType(name: "Fortran 90 Source"),
                                 LanguageType(name: "Fortran Source"),
                                 LanguageType(name: "lig Source"),
                                 LanguageType(name: "JAM Source"),
                                 LanguageType(name: "Java Source"),
                                 LanguageType(name: "Lex Source"),
                                 LanguageType(name: "Metal Shader Source"),
                                 LanguageType(name: "MiG Source"),
                                 LanguageType(name: "OpenCL Source"),
                                 LanguageType(name: "OpenGL Shading Language Source"),
                                 LanguageType(name: "Pascal Source"),
                                 LanguageType(name: "Rez Source"),
                                 LanguageType(name: "Yacc Source")
    ]

    var propertyList = [
        LanguageType(name: "Info plist XML"),
        LanguageType(name: "Property List Binary"),
        LanguageType(name: "Property List Text"),
        LanguageType(name: "Property List XML"),
        LanguageType(name: "XML")
    ]

    var shellList = [
        LanguageType(name: "Bash Shell Script"),
        LanguageType(name: "Shell Script"),
        LanguageType(name: "CSH Shell Script")
    ]

    var machOList = [
        LanguageType(name: "Mach-O Core Dump"),
        LanguageType(name: "Mach-O Dynamic Library"),
        LanguageType(name: "Mach-O FVM Library"),
        LanguageType(name: "Mach-O Object Code"),
        LanguageType(name: "Mach-O Preload Data"),
        LanguageType(name: "Mach-O Bundle")
    ]

    var textList = [
        LanguageType(name: "Cascading Style Sheets"),
        LanguageType(name: "HTML"),
        LanguageType(name: "JSON"),
        LanguageType(name: "Markdown Text"),
        LanguageType(name: "Plain Text"),
        LanguageType(name: "Rich Text Format"),
        LanguageType(name: "YAML")
    ]

    var audioList = [
        LanguageType(name: "AIFF Audio"),
        LanguageType(name: "MIDI Audio"),
        LanguageType(name: "MP3 Audio"),
        LanguageType(name: "WAV Audio"),
        LanguageType(name: "AU Audio")
    ]

    var imageList = [
        LanguageType(name: "BMP Image"),
        LanguageType(name: "GIF Image"),
        LanguageType(name: "Icon"),
        LanguageType(name: "JPEG Image"),
        LanguageType(name: "Microsoft Icon"),
        LanguageType(name: "PICT Image"),
        LanguageType(name: "PNG Image"),
        LanguageType(name: "TIFF Image")
    ]

    var videoList = [
        LanguageType(name: "AVI Video"),
        LanguageType(name: "MPEG Video"),
        LanguageType(name: "QuickTime Video")
    ]

    var archiveList = [
        LanguageType(name: "AppleScript Dictionary Archivo"),
        LanguageType(name: "Archive"),
        LanguageType(name: "BinHex Archive"),
        LanguageType(name: "J2EE Enterprise Archive"),
        LanguageType(name: "Java Archive"),
        LanguageType(name: "MacBinary Archive"),
        LanguageType(name: "PPOB Archive"),
        LanguageType(name: "Resource Archive"),
        LanguageType(name: "Stuffit Archive"),
        LanguageType(name: "Web Application Archive"),
        LanguageType(name: "Zip Archive"),
        LanguageType(name: "gzip Archive"),
        LanguageType(name: "tar Archive")
    ]

    var otherList = [
        LanguageType(name: "API Notes"),
        LanguageType(name: "AppleScript Script Suite Definition"),
        LanguageType(name: "AppleScript Script Terminology Definition"),
        LanguageType(name: "Data"),
        LanguageType(name: "Exported Symbols"),
        LanguageType(name: "Java Bundle"),
        LanguageType(name: "Java Bytecode"),
        LanguageType(name: "LLVM Module Map"),
        LanguageType(name: "Object Code"),
        LanguageType(name: "PDF document"),
        LanguageType(name: "Quartz Composer Composition"),
        LanguageType(name: "Text-Based Dynamic Library Definition"),
        LanguageType(name: "Worksheet Script"),
        LanguageType(name: "Makefile")
    ]

}
