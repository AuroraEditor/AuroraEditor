//
//  Encoding.swift
//  
//
//  Created by Gavin Mao on 4/3/21.
//

import oniguruma
import CoreFoundation

public struct Encoding: Equatable, CustomStringConvertible {
    internal let rawValue: OnigEncoding!

    /// The `String.Encoding` of the corresponding oniguruma encoding.
    public let stringEncoding: String.Encoding

    /**
     Create a `Encoding` with oniguruma `OnigEncoding` pointer.
     
     The `stringEncoding` is populated with a internal map, which only support built-in `OnigEncoding`.
     - Parameter rawValue: The raw oniguruma `OnigEncoding` pointer.
     */
    internal init(rawValue: OnigEncoding!) {
        self.rawValue = rawValue
        self.stringEncoding = Encoding._stringEncoding(from: self.rawValue)
    }

    /// ACSII
    public static let ascii = Encoding(rawValue: &OnigEncodingASCII)

    /// ISO/IEC 8859-1, Latin-1, Western European
    public static let iso8859Part1 = Encoding(rawValue: &OnigEncodingISO_8859_1)

    /// ISO/IEC 8859-2, Latin-2, Central European
    public static let iso8859Part2 = Encoding(rawValue: &OnigEncodingISO_8859_2)

    /// ISO/IEC 8859-3, Latin-3, South European
    public static let iso8859Part3 = Encoding(rawValue: &OnigEncodingISO_8859_3)

    /// ISO/IEC 8859-4, Latin-4, North European
    public static let iso8859Part4 = Encoding(rawValue: &OnigEncodingISO_8859_4)

    /// ISO/IEC 8859-5, Latin/Cyrillic
    public static let iso8859Part5 = Encoding(rawValue: &OnigEncodingISO_8859_5)

    /// ISO/IEC 8859-6, Latin/Arabic
    public static let iso8859Part6 = Encoding(rawValue: &OnigEncodingISO_8859_6)

    /// ISO/IEC 8859-7, Latin/Greek
    public static let iso8859Part7 = Encoding(rawValue: &OnigEncodingISO_8859_7)

    /// ISO/IEC 8859-8, Latin/Hebrew
    public static let iso8859Part8 = Encoding(rawValue: &OnigEncodingISO_8859_8)

    /// ISO/IEC 8859-9, Latin-5/Turkish
    public static let iso8859Part9 = Encoding(rawValue: &OnigEncodingISO_8859_9)

    /// ISO/IEC 8859-10, Latin-6, Nordic
    public static let iso8859Part10 = Encoding(rawValue: &OnigEncodingISO_8859_10)

    /// ISO/IEC 8859-11, Latin/Thai
    public static let iso8859Part11 = Encoding(rawValue: &OnigEncodingISO_8859_11)

    /// ISO/IEC 8859-13, Latin-7, Baltic Rim
    public static let iso8859Part13 = Encoding(rawValue: &OnigEncodingISO_8859_13)

    /// ISO/IEC 8859-14, Latin-8, Celtic
    public static let iso8859Part14 = Encoding(rawValue: &OnigEncodingISO_8859_14)

    /// ISO/IEC 8859-15, Latin-9
    public static let iso8859Part15 = Encoding(rawValue: &OnigEncodingISO_8859_15)

    /// ISO/IEC 8859-16, Latin-10, South-Eastern European
    public static let iso8859Part16 = Encoding(rawValue: &OnigEncodingISO_8859_16)

    /// UTF-8
    public static let utf8 = Encoding(rawValue: &OnigEncodingUTF8)

    /// UTF-16 big endian
    public static let utf16BigEndian = Encoding(rawValue: &OnigEncodingUTF16_BE)

    /// UTF-16 little endian
    public static let utf16LittleEndian = Encoding(rawValue: &OnigEncodingUTF16_LE)

    /// UTF-32 big endian
    public static let utf32BigEndian = Encoding(rawValue: &OnigEncodingUTF32_BE)

    /// UTF-32 little endian
    public static let utf32LittleEndian = Encoding(rawValue: &OnigEncodingUTF32_LE)

    /// EUC JP
    public static let eucJP = Encoding(rawValue: &OnigEncodingEUC_JP)

    /// EUC TW
    public static let eucTW = Encoding(rawValue: &OnigEncodingEUC_TW)

    /// EUC KR
    public static let eucKR = Encoding(rawValue: &OnigEncodingEUC_KR)

    /// EUC CN
    public static let eucCN = Encoding(rawValue: &OnigEncodingEUC_CN)

    /// Shift JIS
    public static let shiftJIS = Encoding(rawValue: &OnigEncodingSJIS)

//    /// KOI-8
//    public static let koi8 = Encoding(rawValue: &OnigEncodingKOI8)

    /// KOI8-R
    public static let koi8r = Encoding(rawValue: &OnigEncodingKOI8_R)

    /// CP1251, Windows-1251
    public static let cp1251 = Encoding(rawValue: &OnigEncodingCP1251)

    /// BIG 5
    public static let big5 = Encoding(rawValue: &OnigEncodingBIG5)

    /// GB 18030
    public static let gb18030 = Encoding(rawValue: &OnigEncodingGB18030)

    /// Get or set the default encoding
    public static var `default`: Encoding {
        get {
            Encoding(rawValue: onigenc_get_default_encoding())
        }

        set {
            onigQueue.sync {
                _ = onigenc_set_default_encoding(newValue.rawValue)
            }
        }
    }

    public var description: String {
        self.stringEncoding.description
    }

    /**
     Map `Encoding`to `String.Encoding`, only built-in encodings are supported.
     */
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private static func _stringEncoding(from onigEncoding: OnigEncoding) -> String.Encoding {
        if onigEncoding == &OnigEncodingASCII { // ACSII
            return .ascii
        } else if onigEncoding == &OnigEncodingISO_8859_1 { // ISO/IEC 8859-1, Latin-1, Western European
            return .isoLatin1
        } else if onigEncoding == &OnigEncodingISO_8859_2 { // ISO/IEC 8859-2, Latin-2, Central European
            return .isoLatin2
        } else if onigEncoding == &OnigEncodingISO_8859_3 { // ISO/IEC 8859-3, Latin-3, South European
            return String.Encoding.SwiftOnig.isoLatin3
        } else if onigEncoding == &OnigEncodingISO_8859_4 { // ISO/IEC 8859-4, Latin-4, North European
            return String.Encoding.SwiftOnig.isoLatin4
        } else if onigEncoding == &OnigEncodingISO_8859_5 { // ISO/IEC 8859-5, Latin/Cyrillic
            return String.Encoding.SwiftOnig.isoLatinCyrillic
        } else if onigEncoding == &OnigEncodingISO_8859_6 { // ISO/IEC 8859-6, Latin/Arabic
            return String.Encoding.SwiftOnig.isoLatinArabic
        } else if onigEncoding == &OnigEncodingISO_8859_7 { // ISO/IEC 8859-7, Latin/Greek
            return String.Encoding.SwiftOnig.isoLatinGreek
        } else if onigEncoding == &OnigEncodingISO_8859_8 { // ISO/IEC 8859-8, Latin/Hebrew
            return String.Encoding.SwiftOnig.isoLatinHebrew
        } else if onigEncoding == &OnigEncodingISO_8859_9 { // ISO/IEC 8859-9, Latin-5/Turkish
            return String.Encoding.SwiftOnig.isoLatin5
        } else if onigEncoding == &OnigEncodingISO_8859_10 { // ISO/IEC 8859-10, Latin-6, Nordic
            return String.Encoding.SwiftOnig.isoLatin6
        } else if onigEncoding == &OnigEncodingISO_8859_11 { // ISO/IEC 8859-11, Latin/Thai
            return String.Encoding.SwiftOnig.isoLatinThai
        } else if onigEncoding == &OnigEncodingISO_8859_13 { // ISO/IEC 8859-13, Latin-7, Baltic Rim
            return String.Encoding.SwiftOnig.isoLatin7
        } else if onigEncoding == &OnigEncodingISO_8859_14 { // ISO/IEC 8859-14, Latin-8, Celtic
            return String.Encoding.SwiftOnig.isoLatin8
        } else if onigEncoding == &OnigEncodingISO_8859_15 { // ISO/IEC 8859-15, Latin-9
            return String.Encoding.SwiftOnig.isoLatin9
        } else if onigEncoding == &OnigEncodingISO_8859_16 { // ISO/IEC 8859-16, Latin-10, South-Eastern European
            return String.Encoding.SwiftOnig.isoLatin10
        } else if onigEncoding == &OnigEncodingUTF8 { // UTF-8
            return .utf8
        } else if onigEncoding == &OnigEncodingUTF16_BE { // UTF-16 big endian
            return .utf16BigEndian
        } else if onigEncoding == &OnigEncodingUTF16_LE { // UTF-16 little endian
            return .utf16LittleEndian
        } else if onigEncoding == &OnigEncodingUTF32_BE { // UTF-32 big endian
            return .utf32BigEndian
        } else if onigEncoding == &OnigEncodingUTF32_LE { // UTF-32 little endian
            return .utf32LittleEndian
        } else if onigEncoding == &OnigEncodingEUC_JP { // EUC JP
            return .japaneseEUC
        } else if onigEncoding == &OnigEncodingEUC_TW { // EUC TW
            return String.Encoding.SwiftOnig.eucTW
        } else if onigEncoding == &OnigEncodingEUC_KR { // EUC KR
            return String.Encoding.SwiftOnig.eucKR
        } else if onigEncoding == &OnigEncodingEUC_CN { // EUC CN
            return String.Encoding.SwiftOnig.eucCN
        } else if onigEncoding == &OnigEncodingSJIS { // Shift JIS
            return .shiftJIS

//        } else if (onigEncoding == &OnigEncodingKOI8) { // KOI-8
//            return nil

        } else if onigEncoding == &OnigEncodingKOI8_R { // KOI8-R
            return String.Encoding.SwiftOnig.koi8r
        } else if onigEncoding == &OnigEncodingCP1251 { // CP1251, Windows-1251
            return .windowsCP1251
        } else if onigEncoding == &OnigEncodingBIG5 { // BIG 5
            return String.Encoding.SwiftOnig.big5
        } else if onigEncoding == &OnigEncodingGB18030 { // GB 18030
            return String.Encoding.SwiftOnig.gb18030
        }

        fatalError("Unexpected encoding")
    }

    /*
     TODO:
     # UChar* onigenc_get_prev_char_head(OnigEncoding enc, const UChar* start, const UChar* s)

       Return previous character head address.

       arguments
       1 enc:   character encoding
       2 start: string address
       3 s:     target address of string

     # UChar* onigenc_get_left_adjust_char_head(OnigEncoding enc,
                                        const UChar* start, const UChar* s)

       Return left-adjusted head address of a character.

       arguments
       1 enc:   character encoding
       2 start: string address
       3 s:     target address of string

     # UChar* onigenc_get_right_adjust_char_head(OnigEncoding enc,
                                                 const UChar* start, const UChar* s)

       Return right-adjusted head address of a character.

       arguments
       1 enc:   character encoding
       2 start: string address
       3 s:     target address of string

     # int onigenc_strlen(OnigEncoding enc, const UChar* s, const UChar* end)

       Return number of characters in the string.

     # int onigenc_strlen_null(OnigEncoding enc, const UChar* s)

       Return number of characters in the string.
       Do not pass invalid byte string in the character encoding.

     # int onigenc_str_bytelen_null(OnigEncoding enc, const UChar* s)

       Return number of bytes in the string.
       Do not pass invalid byte string in the character encoding.

     # void onig_copy_encoding(OnigEncoding to, OnigEncoding from)

       Copy encoding.

       arguments
       1 to:   destination address.
       2 from: source address.
     */
}

extension String.Encoding {
    struct SwiftOnig { // swiftlint:disable:this convenience_type
        static let isoLatin3 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin3.rawValue))
        )
        static let isoLatin4 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin4.rawValue))
        )
        static let isoLatin5 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin5.rawValue))
        )
        static let isoLatin6 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin6.rawValue))
        )
        static let isoLatin7 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin7.rawValue))
        )
        static let isoLatin8 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin8.rawValue))
        )
        static let isoLatin9 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin9.rawValue))
        )
        static let isoLatin10 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatin10.rawValue)))
        static let isoLatinThai = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatinThai.rawValue)))
        static let isoLatinCyrillic = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatinCyrillic.rawValue))
        )
        static let isoLatinArabic = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatinArabic.rawValue))
        )
        static let isoLatinGreek = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatinGreek.rawValue))
        )
        static let isoLatinHebrew = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.isoLatinHebrew.rawValue))
        )
        static let eucCN = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.EUC_CN.rawValue))
        )
        static let eucKR = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
        )
        static let eucTW = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.EUC_TW.rawValue))
        )
        static let koi8r = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.KOI8_R.rawValue))
        )
        static let gb18030 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        )
        static let big5 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
            CFStringEncoding(CFStringEncodings.big5.rawValue))
        )
    }
}
