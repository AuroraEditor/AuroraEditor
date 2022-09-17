//
//  Theme.swift
//  
//
//  Created by Manuel M T Chakravarty on 14/05/2021.
//
//  This module defines code highlight themes.

import SwiftUI

/// A code highlighting theme. Different syntactic elements are purely distinguished by colour.
///
public struct Theme: Identifiable {
  public let id = UUID()

  /// The name of the font to use.
  ///
  public var fontName: String

  /// The point size of the font to use.
  ///
  public var fontSize: CGFloat

  /// The default foreground text colour.
  ///
  public var textColour: OSColor

  /// The colour for (all kinds of) comments.
  ///
  public var commentColour: OSColor

  /// The colour for string literals.
  ///
  public var stringColour: OSColor

  /// The colour for character literals.
  ///
  public var characterColour: OSColor

  /// The colour for number literals.
  ///
  public var numberColour: OSColor

  /// The colour for identifiers.
  ///
  public var identifierColour: OSColor

  /// The colour for keywords.
  ///
  public var keywordColour: OSColor

  /// The background colour.
  ///
  public var backgroundColour: OSColor

  /// The colour of the current line highlight.
  ///
  public var currentLineColour: OSColor

  /// The colour to use for the selection highlight.
  ///
  public var selectionColour: OSColor

  /// The cursor colour.
  ///
  public var cursorColour: OSColor

  /// The colour to use if invisibles are drawn.
  ///
  public var invisiblesColour: OSColor

  public init(fontName: String,
              fontSize: CGFloat,
              textColour: OSColor,
              commentColour: OSColor,
              stringColour: OSColor,
              characterColour: OSColor,
              numberColour: OSColor,
              identifierColour: OSColor,
              keywordColour: OSColor,
              backgroundColour: OSColor,
              currentLineColour: OSColor,
              selectionColour: OSColor,
              cursorColour: OSColor,
              invisiblesColour: OSColor) {
    self.fontName = fontName
    self.fontSize = fontSize
    self.textColour = textColour
    self.commentColour = commentColour
    self.stringColour = stringColour
    self.characterColour = characterColour
    self.numberColour = numberColour
    self.identifierColour = identifierColour
    self.keywordColour = keywordColour
    self.backgroundColour = backgroundColour
    self.currentLineColour = currentLineColour
    self.selectionColour = selectionColour
    self.cursorColour = cursorColour
    self.invisiblesColour = invisiblesColour
  }
}

/// A theme catalog indexing themes by name
///
typealias Themes = [String: Theme]

extension Theme {

    public static var defaultDark: Theme = Theme(
        fontName: "SFMono-Medium",
        fontSize: 13.0,
        textColour: OSColor(red: 0.87, green: 0.87, blue: 0.88, alpha: 1.0),
        commentColour: OSColor(red: 0.51, green: 0.55, blue: 0.59, alpha: 1.0),
        stringColour: OSColor(red: 0.94, green: 0.53, blue: 0.46, alpha: 1.0),
        characterColour: OSColor(red: 0.84, green: 0.79, blue: 0.53, alpha: 1.0),
        numberColour: OSColor(red: 0.84, green: 0.79, blue: 0.53, alpha: 1.0),
        identifierColour: OSColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0),
        keywordColour: OSColor(red: 0.94, green: 0.51, blue: 0.69, alpha: 1.0),
        backgroundColour: OSColor(red: 0.16, green: 0.16, blue: 0.18, alpha: 1.0),
        currentLineColour: OSColor(red: 0.19, green: 0.20, blue: 0.22, alpha: 1.0),
        selectionColour: OSColor(red: 0.40, green: 0.44, blue: 0.51, alpha: 1.0),
        cursorColour: OSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        invisiblesColour: OSColor(red: 0.33, green: 0.37, blue: 0.42, alpha: 1.0)
    )

    public static var defaultLight: Theme = Theme(
        fontName: "SFMono-Regular",
        fontSize: 13.0,
        textColour: OSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0),
        commentColour: OSColor(red: 0.45, green: 0.50, blue: 0.55, alpha: 1.0),
        stringColour: OSColor(red: 0.76, green: 0.24, blue: 0.16, alpha: 1.0),
        characterColour: OSColor(red: 0.14, green: 0.19, blue: 0.81, alpha: 1.0),
        numberColour: OSColor(red: 0.14, green: 0.19, blue: 0.81, alpha: 1.0),
        identifierColour: OSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0),
        keywordColour: OSColor(red: 0.63, green: 0.28, blue: 0.62, alpha: 1.0),
        backgroundColour: OSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        currentLineColour: OSColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0),
        selectionColour: OSColor(red: 0.73, green: 0.84, blue: 0.99, alpha: 1.0),
        cursorColour: OSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
        invisiblesColour: OSColor(red: 0.84, green: 0.84, blue: 0.84, alpha: 1.0)
    )
}

extension Theme {

  /// Font object on the basis of the font name and size of the theme.
  ///
  var font: OSFont {
    if fontName.hasPrefix("SFMono") {

      let weightString = fontName.dropFirst("SFMono".count)
      let weight: OSFont.Weight
      switch weightString {
      case "UltraLight": weight = .ultraLight
      case "Thin":       weight = .thin
      case "Light":      weight = .light
      case "Regular":    weight = .regular
      case "Medium":     weight = .medium
      case "Semibold":   weight = .semibold
      case "Bold":       weight = .bold
      case "Heavy":      weight = .heavy
      case "Black":      weight = .black
      default:           weight = .regular
      }
      return OSFont.monospacedSystemFont(ofSize: fontSize, weight: weight)

    } else {

      return OSFont(name: fontName, size: fontSize) ?? OSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)

    }
  }

  #if os(iOS)

  /// Tint colour on the basis oc the cursor and selection colour of the theme.
  ///
  var tintColour: UIColor {
    var selectionHue = CGFloat(0.0),
        selectionSaturation = CGFloat(0.0),
        selectionBrigthness = CGFloat(0.0),
        cursorHue = CGFloat(0.0),
        cursorSaturation = CGFloat(0.0),
        cursorBrigthness = CGFloat(0.0)

    // TODO: This is awkward...
    selectionColour.getHue(&selectionHue,
                           saturation: &selectionSaturation,
                           brightness: &selectionBrigthness,
                           alpha: nil)
    cursorColour.getHue(&cursorHue, saturation: &cursorSaturation, brightness: &cursorBrigthness, alpha: nil)
    return UIColor(hue: selectionHue,
                   saturation: 1.0,
                   brightness: selectionBrigthness,
                   alpha: 1.0)
  }

  #endif
}
