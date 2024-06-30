//
//  QLHighlighter.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 21/05/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

/// QuickLook highlighter
class QLHighlighter {
    /// The JavaScript code
    let javaScript: String

    /// The CSS code
    let css: String

    /// The code
    var code: String

    /// Initialize the highlighter
    /// 
    /// - Parameter contents: The contents
    init(contents: Data) {
        self.code = (String(data: contents, encoding: .utf8) ?? "Failed to decode")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        guard let cssFilePath = Bundle.main.path(forResource: "highlight", ofType: "css"),
              let cssContents = try? String(contentsOfFile: cssFilePath),
              let jsFilePath = Bundle.main.path(forResource: "highlight", ofType: "js"),
              let jsContents = try? String(contentsOfFile: jsFilePath) else {
            self.javaScript = ""
            self.css = ""
            return
        }

        self.css = cssContents
        self.javaScript = jsContents
    }

    /// Build the HTML
    func build() -> String {
        return """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <style>\(css)</style>
    <script>\(javaScript)</script>
  </head>
  <body>
    <pre><code>\(code)</code></pre>
  </body>
</html>
"""
    }
}
