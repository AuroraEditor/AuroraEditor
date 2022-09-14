//
//  HighlighrTheme.swift
//  Pods
//
//  Created by Illanes, J.P. on 4/24/16.
//
//

import Foundation

import AppKit
public typealias RPColor = NSColor
public typealias RPFont = NSFont

private typealias RPThemeDict = [String: [AnyHashable: AnyObject]]
private typealias RPThemeStringDict = [String: [String: String]]

/// Theme parser, can be used to configure the theme parameters.
open class HighlighrTheme {
    internal let theme: String
    internal var lightTheme: String!

    /// Regular font to be used by this theme
    open var codeFont: RPFont!
    /// Bold font to be used by this theme
    open var boldCodeFont: RPFont!
    /// Italic font to be used by this theme
    open var italicCodeFont: RPFont!

    private var themeDict: RPThemeDict!
    private var strippedTheme: RPThemeStringDict!

    /// Default background color for the current theme.
    open var themeBackgroundColor: RPColor!

    /**
     Initialize the theme with the given theme name.
     
     - parameter themeString: Theme to use.
     */
    public init(themeString: String) {
        theme = themeString
        setCodeFont(NSFont.monospacedSystemFont(ofSize: 14, weight: .medium))
        strippedTheme = stripTheme(themeString)
        lightTheme = strippedThemeToString(strippedTheme)
        themeDict = strippedThemeToTheme(strippedTheme)
        var bkgColorHex = strippedTheme[".hljs"]?["background"]
        if bkgColorHex == nil {
            bkgColorHex = strippedTheme[".hljs"]?["background-color"]
        }
        if let bkgColorHex = bkgColorHex {
            if bkgColorHex == "white" {
                themeBackgroundColor = RPColor(white: 1, alpha: 1)
            } else if bkgColorHex == "black" {
                themeBackgroundColor = RPColor(white: 0, alpha: 1)
            } else {
                let range = bkgColorHex.range(of: "#")
                let str = String(bkgColorHex[(range?.lowerBound)!...])
                themeBackgroundColor = colorWithHexString(str)
            }
        } else {
            themeBackgroundColor = RPColor.white
        }
    }

    /**
     Changes the theme font. This will try to automatically populate the codeFont,
     boldCodeFont and italicCodeFont properties based on the provided font.
     
     - parameter font: UIFont (iOS or tvOS) or NSFont (OSX)
     */
    open func setCodeFont(_ font: RPFont) {
        codeFont = font

        let obliqueDescriptor = NSFontDescriptor(
            fontAttributes: [.family: font.familyName!,
                             .face: "Oblique"])

        boldCodeFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .bold)
        italicCodeFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .medium)

        if italicCodeFont == nil || italicCodeFont.familyName != font.familyName {
            italicCodeFont = RPFont(descriptor: obliqueDescriptor, size: font.pointSize)
        }
        if italicCodeFont == nil {
            italicCodeFont = font
        }

        if boldCodeFont == nil {
            boldCodeFont = font
        }

        if themeDict != nil {
            themeDict = strippedThemeToTheme(strippedTheme)
        }
    }

    internal func applyStyleToString(_ string: String, styleList: [String]) -> NSAttributedString {
        let returnString: NSAttributedString

        if !styleList.isEmpty {
            var attrs = [AttributedStringKey: Any]()
            attrs[.font] = codeFont
            for style in styleList {
                var style = style

                if styleList.contains("hljs-title") &&
                    styleList.contains("hljs-function") &&
                    themeDict["hljs-function-hljs-title"] != nil {
                    style = "hljs-function-hljs-title"
                }

                if styleList.contains("hljs-title") &&
                    styleList.contains("hljs-class") &&
                    themeDict["hljs-class-hljs-title"] != nil {
                    style = "hljs-class-hljs-title"
                }
                if let themeStyle = themeDict[style] as? [AttributedStringKey: Any] {
                    for (attrName, attrValue) in themeStyle {
                        attrs.updateValue(attrValue, forKey: attrName)
                    }
                }
            }

            returnString = NSAttributedString(string: string, attributes: attrs )
        } else {
            returnString = NSAttributedString(string: string, attributes: [AttributedStringKey.font: codeFont as Any] )
        }

        return returnString
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func stripTheme(_ themeString: String) -> [String: [String: String]] {
        let objcString = (themeString as NSString)
        guard let cssRegex = try? NSRegularExpression(
            pattern: "(?:(\\.[a-zA-Z0-9\\-_]*(?:[, ]\\.[a-zA-Z0-9\\-_]*)*)\\{([^\\}]*?)\\})",
            options: [.caseInsensitive]
        ) else {
            fatalError("Should never happen")
        }

        let results = cssRegex.matches(in: themeString,
                                       options: [.reportCompletion],
                                       range: NSRange(location: 0, length: objcString.length))

        var resultDict = [String: [String: String]]()

        for result in results where result.numberOfRanges == 3 {
                var attributes = [String: String]()
                let cssPairs = objcString.substring(with: result.range(at: 2)).components(separatedBy: ";")
                for pair in cssPairs {
                    let cssPropComp = pair.components(separatedBy: ":")
                    if cssPropComp.count == 2 {
                        attributes[cssPropComp[0]] = cssPropComp[1]
                    }

                }
                if !attributes.isEmpty {
                    resultDict[objcString.substring(with: result.range(at: 1))] = attributes
                }
        }

        var returnDict = [String: [String: String]]()

        for (keys, result) in resultDict {
            let keyArray = keys.replacingOccurrences(of: " ", with: ",").components(separatedBy: ",")
            for key in keyArray {

                var key = key
                if keyArray.contains(".hljs-title") && keyArray.contains(".hljs-function") {
                    key = "hljs-function-hljs-title"
                }

                if keyArray.contains(".hljs-title") && keyArray.contains(".hljs-class") {
                    key = "hljs-class-hljs-title"
                }

                var props: [String: String]?
                props = returnDict[key]
                if props == nil {
                    props = [String: String]()
                }

                for (pName, pValue) in result {
                    props!.updateValue(pValue, forKey: pName)
                }
                returnDict[key] = props!
            }
        }

        return returnDict
    }

    private func strippedThemeToString(_ theme: RPThemeStringDict) -> String {
        var resultString = ""
        for (key, props) in theme {
            resultString += key+"{"
            for (cssProp, val) in props {
                if key != ".hljs" ||
                    (cssProp.lowercased() != "background-color"
                     && cssProp.lowercased() != "background") {
                    resultString += "\(cssProp):\(val);"
                }
            }
            resultString+="}"
        }
        return resultString
    }

    private func strippedThemeToTheme(_ theme: RPThemeStringDict) -> RPThemeDict {
        var returnTheme = RPThemeDict()
        for (className, props) in theme {
            var keyProps = [AttributedStringKey: AnyObject]()
            for (key, prop) in props {
                switch key {
                case "color":
                    keyProps[attributeForCSSKey(key)] = colorWithHexString(prop)

                case "font-style":
                    keyProps[attributeForCSSKey(key)] = fontForCSSStyle(prop)

                case "font-weight":
                    keyProps[attributeForCSSKey(key)] = fontForCSSStyle(prop)

                case "background-color":
                    keyProps[attributeForCSSKey(key)] = colorWithHexString(prop)

                default:
                    break
                }
            }
            if !keyProps.isEmpty {
                let key = className.replacingOccurrences(of: ".", with: "")
                returnTheme[key] = keyProps
            }
        }
        return returnTheme
    }

    private func fontForCSSStyle(_ fontStyle: String) -> RPFont {
        switch fontStyle {
        case "bold", "bolder", "600", "700", "800", "900":
            return boldCodeFont
        case "italic", "oblique":
            return italicCodeFont
        default:
            return codeFont
        }
    }

    private func attributeForCSSKey(_ key: String) -> AttributedStringKey {
        switch key {
        case "color":
            return .foregroundColor
        case "font-weight":
            return .font
        case "font-style":
            return .font
        case "background-color":
            return .backgroundColor
        default:
            return .font
        }
    }

    // swiftlint:disable:next function_body_length
    private func colorWithHexString (_ hex: String) -> RPColor {
        var cString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        } else {
            switch cString {
            case "white":
                return RPColor(white: 1, alpha: 1)
            case "black":
                return RPColor(white: 0, alpha: 1)
            case "red":
                return RPColor(red: 1, green: 0, blue: 0, alpha: 1)
            case "green":
                return RPColor(red: 0, green: 1, blue: 0, alpha: 1)
            case "blue":
                return RPColor(red: 0, green: 0, blue: 1, alpha: 1)
            default:
                return RPColor.gray
            }
        }

        if cString.count != 6 && cString.count != 3 {
            return RPColor.gray
        }

        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        var divisor: CGFloat

        if cString.count == 6 {
            let rString = (cString as NSString).substring(to: 2)
            let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
            let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)

            Scanner(string: rString).scanHexInt64(&red)
            Scanner(string: gString).scanHexInt64(&green)
            Scanner(string: bString).scanHexInt64(&blue)

            divisor = 255.0
        } else {
            let rString = (cString as NSString).substring(to: 1)
            let gString = ((cString as NSString).substring(from: 1) as NSString).substring(to: 1)
            let bString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 1)

            Scanner(string: rString).scanHexInt64(&red)
            Scanner(string: gString).scanHexInt64(&green)
            Scanner(string: bString).scanHexInt64(&blue)

            divisor = 15.0
        }

        return RPColor(
            red: CGFloat(red) / divisor,
            green: CGFloat(green) / divisor,
            blue: CGFloat(blue) / divisor,
            alpha: CGFloat(1)
        )
    }

}
