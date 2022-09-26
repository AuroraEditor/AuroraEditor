# Editor

Custom language grammar tokenizer and theming/syntax highlighter with integrated editor written in Swift, designed for use in both macOS and iOS.

Based on the <a href="https://macromates.com/manual/en/language_grammars">Textmate Grammar</a> language and <a href="https://github.com/microsoft/vscode-textmate">vscode's implementation</a>. Contains a subset of the textmate grammar features with it's own extensions.

Goal: To create an flexible advanced text editor framework so that any app that needs to create an editor with non-trivial features, small or little, can add them easily.

## Installation
Currently Editor is only available through the Swift Package Manager tooling and yet to have a major release. So add the following to your `Package.swift` file:
```
.package(url: "https://github.com/mattDavo/Editor", .branch("master"))
```

## Example Usage
Head over to [EditorExample](https://github.com/mattDavo/EditorExample) to see Editor used in a larger project example.

We recommend reading the [full documentation](https://github.com/mattDavo/Editor/blob/master/DOCUMENTATION.md) to best understand how to create your best editor. However, here is a quick example of what you can use editor to do:

![EditorReadMeExampleGif](https://github.com/mattDavo/Editor/blob/master/Images/EditorReadMeExample.gif)

This is all possible with the following snippets of code.

First you will create a grammar. This is the definition of your language:

```Swift
import EditorCore

let readMeExampleGrammar = Grammar(
    scopeName: "source.example",
    fileTypes: [],
    patterns: [
        MatchRule(name: "keyword.special.class", match: "\\bclass\\b"),
        MatchRule(name: "keyword.special.let", match: "\\blet\\b"),
        MatchRule(name: "keyword.special.var", match: "\\bvar\\b"),
        BeginEndRule(
            name: "string.quoted.double",
            begin: "\"",
            end: "\"",
            patterns: [
                MatchRule(name: "source.example", match: #"\\\(.*\)"#, captures: [
                    Capture(patterns: [IncludeGrammarPattern(scopeName: "source.example")])
                ])
            ]
        ),
        BeginEndRule(name: "comment.line.double-slash", begin: "//", end: "\\n", patterns: [IncludeRulePattern(include: "todo")]),
        BeginEndRule(name: "comment.block", begin: "/\\*", end: "\\*/", patterns: [IncludeRulePattern(include: "todo")])
    ],
    repository: Repository(patterns: [
        "todo": MatchRule(name: "comment.keyword.todo", match: "TODO")
    ])
)
```

Next you will create a Theme. This is how the scopes of your tokens (text divided based on the grammar) are formatted:

```Swift
import EditorCore
import EditorUI

let readMeExampleTheme = Theme(name: "basic", settings: [
    ThemeSetting(scope: "comment", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemGreen)
    ]),
    ThemeSetting(scope: "keyword", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemBlue)
    ]),
    ThemeSetting(scope: "string", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemRed)
    ]),
    ThemeSetting(scope: "source", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .textColor),
        FontThemeAttribute(font: .monospacedSystemFont(ofSize: 18)),
        TailIndentThemeAttribute(value: -30)
    ]),
    ThemeSetting(scope: "comment.keyword", parentScopes: [], attributes: [
        ColorThemeAttribute(color: .systemTeal)
    ])
])
```

Finally we will take our `NSTextView` subclass `EditorTextView` and give it to our `Editor` with the grammar and theme.
```Swift
import Cocoa
import EditorCore
import EditorUI

class ViewController: NSViewController {

    @IBOutlet var textView: EditorTextView!
    var editor: Editor!
    var parser: Parser!

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.insertionPointColor = .systemBlue
        textView.replace(lineNumberGutter: LineNumberGutter(withTextView: textView))

        parser = Parser(grammars: [readMeExampleGrammar])
        editor = Editor(textView: textView, parser: parser, baseGrammar: readMeExampleGrammar, theme: exampleTheme)
    }
}
```

We can also apply the same `Grammar` and `Theme` to an iOS version of the app, like so:
```Swift
import UIKit
import EditorCore
import EditorUI

class ViewController: UIViewController {

    var textView: EditorTextView!
    var parser: Parser!
    var editor: Editor!

    override func viewDidLoad() {
        super.viewDidLoad()

        textView = .create(frame: view.frame)
        view.addSubview(textView)

        textView.text = bigText
        textView.linkTextAttributes?.removeValue(forKey: .foregroundColor)

        parser = Parser(grammars: [exampleGrammar, basicSwiftGrammar])
        parser.shouldDebug = false
        editor = Editor(textView: textView, parser: parser, baseGrammar: exampleGrammar, theme: exampleTheme)
    }
}
```
However, Editor for iOS does contain the full breadth of features that are for macOS.

And voilà! With the appropriate settings in the interface builder this will produce the nice editor above.

Be sure to read the [Documentation](https://github.com/mattDavo/Editor/blob/master/DOCUMENTATION.md) to understand what the above code is doing so that you can create your own editors!


## Features
### Apply any `NSAttributedString` attributes to a given token.
Using any of the pre-defined `ThemeAttribute`s defined in EditorUI or write your own by implementing the `TokenThemeAttribute` or `LineThemeAttribute` protocol.

### Apply custom Editor attributes to a given token.
#### Rounded background colors
Customizable corner radius and style.

Token only:

![](Images/roundedBackgroundColor.png?raw=true)

Full line:
![](Images/roundedBackgroundColor2.png?raw=true)


#### Hidden attributes.
Hide certain tokens.


#### Actions.
Make tokens clickable, and add a handler.


### Apply different attributes to a given token when the cursor is and isn't in the paragraph.
Cursor in the paragraph:
![](Images/inSelectionExample.png?raw=true)

Cursor out of the paragraph.
![](Images/outSelectionExample.png?raw=true)


### Subscribe to all the `MatchRule` tokens.
For example you can easily get all the tags in the document.
```Swift
editor.subscribe(toToken: "tag")
```
This works for all `MatchRule` tokens, even with captures in them. This makes getting all of the tokens of a certain type much easier when a `MatchRule` has complex captures. For example, a Swift string with interpolation.


### Customizable Editor
#### Add line numbers
```Swift
textView.replace(lineNumberGutter: LineNumberGutter(withTextView: textView))
```

#### Indent Using Spaces
```Swift
textView.indentUsingSpaces = true
textView.tabWidth = 4
```

#### Auto Indent
```Swift
textView.autoIndent = true
```

#### Customize Caret Width
```Swift
textView.caretSize = 4
```

## Contributing

Contributions are welcomed and encouraged. Feel free to raise pull requests, raise issues for bugs or new features, write tests or [contact me](mailto:mattdavo15@gmail.com) if you think you can help.

### TODO
##### EditorCore
- [ ] Captures for `BeginEndRule`
- [ ] Folding stop and start markers
- [ ] Parent scopes for `ThemeSetting`s
- [ ] Refactor `Rule` matching into the `protocol`


##### EditorUI
- [x] Clickable/tappable tokens with handlers
- [ ] Token replacements, take a token and replace the text.
- [x] State-conditional formatting: based on the position of the cursor
- [ ] Use temporary attributes instead of the EditorTextStorage where possible for better performance.


##### All
- [x] Subscribe to tokens, changes
- [ ] Auto-completion and suggestions
- [ ] Smarter auto-indent, based on scope to determine depth of indent.

##### Optimization of Syntax Highlighting
- [ ] `EditorTextStorage: NSTextStorage`
    - [ ] Re-write in ObjC because the bridging is expensive and can be up to 3 times faster. See:
        - https://mjtsai.com/blog/2019/02/22/swift-subclass-of-nstextstorage-is-slow-because-of-swift-bridging/
        - https://www.reddit.com/r/swift/comments/7hcxlt/whats_your_experience_using_swift_to_handle_large/
    - [x] Pre-compute the ranges of lines, so splitting the entire text into lines on every edit is not necessary
    - [ ] Limit the use of fixAttributes(). Currently it is being used on the entire range of the re-formatted text, which could mean characters such as emojis that may only be typed once could end up being reformatted over and over again when an edit causes that line to be reformatted.
- [ ] Improve the theme attribute computation and it's storage in the `Scope`/`Token`.
- [ ] Use temporary attributes instead of the EditorTextStorage where possible.


### Recommended Reading for `EditorCore`

To best understand how textmate grammars work and the parsers are implemented, look over the following:
- [Textmate language grammars](https://macromates.com/manual/en/language_grammars)
- [Textmate scope selectors](https://macromates.com/manual/en/scope_selectors]=)
- [Writing a textmate grammar](https://www.apeth.com/nonblog/stories/textmatebundle.html)
- [VSCode implementation](https://github.com/microsoft/vscode-textmate)
- [VSCode syntax highlighting optimizations](https://code.visualstudio.com/blogs/2017/02/08/syntax-highlighting-optimizations)
- [Iro syntax highligher](https://medium.com/@model_train/creating-universal-syntax-highlighters-with-iro-549501698fd2)
- [Sublime text syntax highlighter - very high performance](https://github.com/trishume/syntect)
- [Editor Documentation!](https://github.com/mattDavo/Editor/blob/master/DOCUMENTATION.md) 😜

### Recommended Reading for `EditorUI`
TextKit and in particular, subclassing the various TextKit models can be difficult and confusing at times, here are some good links to look over if you're trying to digest something in the codebase or why certain behaviour is the way it is.
- [Performing syntax highlighting](https://christiantietze.de/posts/2017/11/syntax-highlight-nstextstorage-insertion-point-change/) - In particular the comment section!
- [Implementing code completion](https://stackoverflow.com/a/16754457)

## License
Available under the [MIT License](https://github.com/mattDavo/Editor/blob/master/LICENSE)
