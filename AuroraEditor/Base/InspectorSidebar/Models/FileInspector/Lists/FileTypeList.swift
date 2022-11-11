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
        LanguageType(name: "Objective-C(++) Source", ext: "m")
    ]

    var sourcecodeCList = [
        LanguageType(name: "C Header", ext: "h"),
        LanguageType(name: "C Source", ext: "c")
    ]

    var sourcecodeCPlusList = [
        LanguageType(name: "C++ Header", ext: "hpp"),
        LanguageType(name: "C++ Source", ext: "cpp")
    ]

    var sourcecodeSwiftList = [
        LanguageType(name: "Swift Source", ext: "swift")
    ]

    var sourcecodeAssemblyList = [
        LanguageType(name: "Assembly", ext: "asm"),
        LanguageType(name: "LLVM Assembly", ext: "ll")
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
        LanguageType(name: "Rez Source", ext: "r"),
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
        LanguageType(name: "CSH Shell Script", ext: "csh")
    ]

    var machOList = [
        LanguageType(name: "Mach-O Object Code", ext: "o"),
        LanguageType(name: "Mach-O Dynamic Library", ext: "dylb"),
        LanguageType(name: "Mach-O Bundle", ext: "bundle")
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
