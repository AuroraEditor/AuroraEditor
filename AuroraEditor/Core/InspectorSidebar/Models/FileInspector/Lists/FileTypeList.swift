//
//  FileTypeList.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// A collection of file types and their associated extensions,
///  which can be selected in the inspector to override default values
final class FileTypeList {
    /// Aurora Editor project file
    var languageTypeAuroraEditor = [
        LanguageType(name: "Aurora Editor Project", ext: "aeproj")
    ]

    /// Objective-C source file
    var languageTypeObjCList = [
        LanguageType(name: "Objective-C(++) Source", ext: "m")
    ]

    /// C source file
    var sourcecodeCList = [
        LanguageType(name: "C Header", ext: "h"),
        LanguageType(name: "C Source", ext: "c")
    ]

    /// C++ source file
    var sourcecodeCPlusList = [
        LanguageType(name: "C++ Header", ext: "hpp"),
        LanguageType(name: "C++ Source", ext: "cpp")
    ]

    /// Swift source file
    var sourcecodeSwiftList = [
        LanguageType(name: "Swift Source", ext: "swift")
    ]

    /// Assembly source file
    var sourcecodeAssemblyList = [
        LanguageType(name: "Assembly", ext: "asm"),
        LanguageType(name: "LLVM Assembly", ext: "ll")
    ]

    /// Source code script file
    var sourcecodeScriptList = [
        LanguageType(name: "AppleScript Uncompiled Source", ext: "?ASUS"),
        LanguageType(name: "JavaScript Source", ext: "js"),
        LanguageType(name: "PHP Script", ext: "php"),
        LanguageType(name: "Perl Script", ext: "pl"),
        LanguageType(name: "Python Script", ext: "py"),
        LanguageType(name: "Ruby Script", ext: "rb")
    ]

    /// Source code various files
    var sourcecodeVariousList = [
        LanguageType(name: "Ada Source", ext: "ads"),
        LanguageType(name: "DTrace Source", ext: "dtrace"),
        LanguageType(name: "Fortran 77 Source", ext: "f77"),
        LanguageType(name: "Fortran 90 Source", ext: "f90"),
        LanguageType(name: "Fortran Source", ext: "f"),
        LanguageType(name: "JAM Source", ext: "jam"),
        LanguageType(name: "Java Source", ext: "java"),
        LanguageType(name: "Lex Source", ext: "lex"),
        LanguageType(name: "Metal Shader Source", ext: "metal"),
        LanguageType(name: "Mach Interface Generator Source", ext: "defs"),
        LanguageType(name: "OpenCL Source", ext: "cl"),
        LanguageType(name: "OpenGL Shading Language Source", ext: "clpp"),
        LanguageType(name: "Pascal Source", ext: "pas"),
        LanguageType(name: "Rez Source", ext: "r")
    ]

    /// Property list files
    var propertyList = [
        LanguageType(name: "Property List Binary", ext: "bplist"),
        LanguageType(name: "Property List Text", ext: "?pplist"),
        LanguageType(name: "Property List XML", ext: "plist"),
        LanguageType(name: "XML", ext: "xml")
    ]

    /// Shell script files
    var shellList = [
        LanguageType(name: "Bash Shell Script", ext: "sh"),
        LanguageType(name: "Shell Script", ext: "command"),
        LanguageType(name: "CSH Shell Script", ext: "csh")
    ]

    /// Mach-O files
    var machOList = [
        LanguageType(name: "Mach-O Object Code", ext: "o"),
        LanguageType(name: "Mach-O Dynamic Library", ext: "dylb"),
        LanguageType(name: "Mach-O Bundle", ext: "bundle")
    ]

    /// Text files
    var textList = [
        LanguageType(name: "Cascading Style Sheets", ext: "css"),
        LanguageType(name: "HTML", ext: "html"),
        LanguageType(name: "JSON", ext: "json"),
        LanguageType(name: "Markdown Text", ext: "md"),
        LanguageType(name: "Plain Text", ext: "txt"),
        LanguageType(name: "Rich Text Format", ext: "rtf"),
        LanguageType(name: "YAML", ext: "yaml")
    ]

    /// Audio files
    var audioList = [
        LanguageType(name: "AIFF Audio", ext: "aiff"),
        LanguageType(name: "MIDI Audio", ext: "midi"),
        LanguageType(name: "MP3 Audio", ext: "mp3"),
        LanguageType(name: "WAV Audio", ext: "wav"),
        LanguageType(name: "AU Audio", ext: "au")
    ]

    /// Image files
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

    /// Video files
    var videoList = [
        LanguageType(name: "AVI Video", ext: "avi"),
        LanguageType(name: "MPEG Video", ext: "mp4"),
        LanguageType(name: "QuickTime Video", ext: "mov")
    ]

    /// Archive files
    var archiveList = [
        LanguageType(name: "BinHex Archive", ext: "binhex"),
        LanguageType(name: "J2EE Enterprise Archive", ext: "j2ee"),
        LanguageType(name: "Java Archive", ext: "jar"),
        LanguageType(name: "MacBinary Archive", ext: "mba"),
        LanguageType(name: "Stuffit Archive", ext: "sit"),
        LanguageType(name: "Web Application Archive", ext: "war"),
        LanguageType(name: "Zip Archive", ext: "zip"),
        LanguageType(name: "gzip Archive", ext: "gzip"),
        LanguageType(name: "tar Archive", ext: "tar")
    ]

    /// Other files
    var otherList = [
        LanguageType(name: "AppleScript", ext: "applescript"),
        LanguageType(name: "AppleScript Script Suite Definition", ext: "scpt"),
        LanguageType(name: "AppleScript Script Terminology Definition", ext: "scptd"),
        LanguageType(name: "Exported Symbols", ext: "symbols"),
        LanguageType(name: "Java Bytecode", ext: "class"),
        LanguageType(name: "Object Code", ext: "o"),
        LanguageType(name: "PDF document", ext: "pdf"),
        LanguageType(name: "Quartz Composer Composition", ext: "qtz"),
        LanguageType(name: "Text-Based Dynamic Library Definition", ext: "tbdld"),
        LanguageType(name: "Makefile", ext: "markdown")
    ]

}
