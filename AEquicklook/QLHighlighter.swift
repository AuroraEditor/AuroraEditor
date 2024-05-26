//
//  QLHighlighter.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 21/05/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Foundation

class QLHighlighter {
    let javaScript: String
    let css: String
    var code: String

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
