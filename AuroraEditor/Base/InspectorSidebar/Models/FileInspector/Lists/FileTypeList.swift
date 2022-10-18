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
    var languageTypeAuroraEditor = [
        LanguageType(name: "Aurora Editor Project", ext: "aeproj")
    ]

    var languageTypeObjCList = [
        // TODO: Get correct extension, or remove
        LanguageType(name: "Objective-C(++) Preprocessed Source", ext: "?opc"),
        LanguageType(name: "Objective-C(++) Source", ext: "m")
    ]

    var sourcecodeCList = [
        LanguageType(name: "C Header", ext: "h"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "C Preprocessed Source", ext: "?cps"),
        LanguageType(name: "C Source", ext: "c")
    ]

    var sourcecodeCPlusList = [
        LanguageType(name: "C++ Header", ext: "hpp"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "C++ Preprocessed Source", ext: "?cppps"),
        LanguageType(name: "C++ Source", ext: "cpp")
    ]

    var sourcecodeSwiftList = [
        LanguageType(name: "Swift Source", ext: "swift")
    ]

    var sourcecodeAssemblyList = [
        LanguageType(name: "Assembly", ext: "asm"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "LLVM Assembly", ext: "?llvm"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "NASM Assembly", ext: "?nasm"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "PPC Assembly", ext: "?ppc")
    ]

    var sourcecodeScriptList = [
        LanguageType(name: "AppleScript Uncompiled Source", ext: "?ASUS"),
        LanguageType(name: "JavaScript Source", ext: "js"),
        LanguageType(name: "PHP Script", ext: "php"),
        LanguageType(name: "Perl Script", ext: "pl"),
        LanguageType(name: "Python Script", ext: "py"),
        LanguageType(name: "Ruby Script", ext: "rb")
    ]

    var sourcecodeVariousList = [
        // TODO: Get correct extension, or remove
        LanguageType(name: "Ada Source", ext: "?ada"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "CLIPS Source", ext: "?clips"),
        LanguageType(name: "DTrace Source", ext: "dtrace"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Fortran 77 Source", ext: "?f77"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Fortran 90 Source", ext: "?f90"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Fortran Source", ext: "?f"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "lig Source", ext: "?lig"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "JAM Source", ext: "?jam"),
        LanguageType(name: "Java Source", ext: "java"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Lex Source", ext: "?lex"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Metal Shader Source", ext: "?mss"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "MiG Source", ext: "?mig"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "OpenCL Source", ext: "?opencl"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "OpenGL Shading Language Source", ext: "opengl"),
        LanguageType(name: "Pascal Source", ext: "pas"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Rez Source", ext: "?rez"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Yacc Source", ext: "?yazz ")
    ]

    var propertyList = [
        LanguageType(name: "Property List Binary", ext: "bplist"),
        LanguageType(name: "Property List Text", ext: "?pplist"),
        LanguageType(name: "Property List XML", ext: "plist"),
        LanguageType(name: "XML", ext: "xml")
    ]

    var shellList = [
        LanguageType(name: "Bash Shell Script", ext: "sh"),
        LanguageType(name: "Shell Script", ext: "command"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "CSH Shell Script", ext: "?ccommand")
    ]

    var machOList = [
        // TODO: Get correct extension, or remove
        LanguageType(name: "Mach-O Core Dump", ext: "?mocd"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Mach-O Dynamic Library", ext: "?dylb"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Mach-O FVM Library", ext: "?fvm"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Mach-O Object Code", ext: "o"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Mach-O Preload Data", ext: "?pd"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Mach-O Bundle", ext: "?MOB")
    ]

    var textList = [
        LanguageType(name: "Cascading Style Sheets", ext: "css"),
        LanguageType(name: "HTML", ext: "html"),
        LanguageType(name: "JSON", ext: "json"),
        LanguageType(name: "Markdown Text", ext: "md"),
        LanguageType(name: "Plain Text", ext: "txt"),
        LanguageType(name: "Rich Text Format", ext: "rtf"),
        LanguageType(name: "YAML", ext: "yaml")
    ]

    var audioList = [
        LanguageType(name: "AIFF Audio", ext: "aiff"),
        LanguageType(name: "MIDI Audio", ext: "midi"),
        LanguageType(name: "MP3 Audio", ext: "mp3"),
        LanguageType(name: "WAV Audio", ext: "wav"),
        LanguageType(name: "AU Audio", ext: "au")
    ]

    var imageList = [
        LanguageType(name: "BMP Image", ext: "bmp"),
        LanguageType(name: "GIF Image", ext: "gif"),
        LanguageType(name: "Icon", ext: "icon"),
        LanguageType(name: "JPEG Image", ext: "jpg"),
        LanguageType(name: "JPEG Image", ext: "jpeg"),
        LanguageType(name: "Microsoft Icon", ext: "ico"),
        LanguageType(name: "PICT Image", ext: "pict"),
        LanguageType(name: "PNG Image", ext: "png"),
        LanguageType(name: "TIFF Image", ext: "tiff")
    ]

    var videoList = [
        LanguageType(name: "AVI Video", ext: "avi"),
        LanguageType(name: "MPEG Video", ext: "mp4"),
        LanguageType(name: "QuickTime Video", ext: "mov")
    ]

    var archiveList = [
        // TODO: Get correct extension, or remove
        LanguageType(name: "AppleScript Dictionary Archivo", ext: "?ada"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Archive", ext: "?archive"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "BinHex Archive", ext: "?binhex"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "J2EE Enterprise Archive", ext: "?j2ee"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Java Archive", ext: "?ja"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "MacBinary Archive", ext: "?mba"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "PPOB Archive", ext: "?ppoba"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Resource Archive", ext: "?ra"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Stuffit Archive", ext: "?stuffit"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Web Application Archive", ext: "?waa"),
        LanguageType(name: "Zip Archive", ext: "zip"),
        LanguageType(name: "gzip Archive", ext: "gzip"),
        LanguageType(name: "tar Archive", ext: "tar")
    ]

    var otherList = [
        // TODO: Get correct extension, or remove
        LanguageType(name: "API Notes", ext: "?apin"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "AppleScript Script Suite Definition", ext: "?asst"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "AppleScript Script Terminology Definition", ext: "?astd"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Data", ext: "?data"),
        LanguageType(name: "Exported Symbols", ext: "symbols"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Java Bundle", ext: "?javab"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Java Bytecode", ext: "?jb"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "LLVM Module Map", ext: "?lvvm"),
        LanguageType(name: "Object Code", ext: "o"),
        LanguageType(name: "PDF document", ext: "pdf"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Quartz Composer Composition", ext: "?qcc"),
        LanguageType(name: "Text-Based Dynamic Library Definition", ext: "tbdld"),
        // TODO: Get correct extension, or remove
        LanguageType(name: "Worksheet Script", ext: "?worksheetscript"),
        LanguageType(name: "Makefile", ext: "markdown")
    ]

}
