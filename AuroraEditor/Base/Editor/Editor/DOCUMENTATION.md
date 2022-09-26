# Editor Documentation

## Introduction
Editor is composed of two products:
- `EditorCore`: Model definition and implementation of tokenization and theming.
- `EditorUI`: Integration with TextKit for use with NSTextView and UITextView.

You will very likely be using both, keep reading for how to use them.

## `EditorCore`
Most of your interaction with `EditorCore` will be defining your language grammars, themes and setting up your parser.

## Grammar
A grammar is a definition of the langauge structure. It allows us to tokenize the text into distinct tokens with all of the scope that each token has so that we can apply context-aware syntax highlighting. For example, if a grammar was defined for the Swift programming langauge and we had the following code:
```Swift
let score = 10

let str = "I rate Editor\(score)/10"
```
We would receive tokens such as `let` with a "keyword" (or whatever it was named) scope.

Now, this doesn't stop there. Scopes can be accumulated and stack on top of each other which makes the syntax highlighting aware. So language grammars start out with a base scope named something like "source.swift". This would mean that `let` would have scopes: `source.swift`, `keyword`. And then `score` inside the string might have something like: `source.swift`, `string.quoted.double`, `source.swift`, `variable.local`.

Let's look at how we define a grammar.

Grammars have the following constructor
```Swift
public init(
    scopeName: String,
    fileTypes: [String] = [],
    patterns: [Pattern] = [],
    foldingStartMarker: String? = nil,
    foldingStopMarker: String? = nil,
    repository: Repository? = nil
)
```
- `scopeName` is the base scope for the text. E.g. `source.swift`.
- `fileTypes` are the file types to use the grammar for. **NOT YET IMPLEMENTED**
- `patterns` are base scope level patterns.
- `foldingStartMarker` **NOT YET IMPLEMENTED**
- `foldingStopMarker` **NOT YET IMPLEMENTED**
- `repository` is the repository of patterns that can referenced from the list of patterns.

Ok, this begs the question, what is a pattern?

## Patterns and Rules
Patterns define the grammar structure so that the text can be split into tokens. The magic to the context-aware tokenization is that patterns can be recursive. This can make defining structure recursive, so we make a distinction between `Pattern`s and `Rules`s, by defining a `Rule` as a `Pattern` that has been resolved and can be applied to the text. So `Pattern`s are simply defined in the grammar, and then turned into concrete `Rule`s when they need to be applied to text.

Types of Patterns:
- `MatchRule`: Matches a single line regex. Already a concrete rule due to its concrete definition. Used for things like keywords.
- `BeginEndRule`: Has a begin regex and end regex, can span multiple lines and can have patterns to apply in between. Usef for patterns like multi-line comments. 
- `IncludeRulePattern`: Refernces a pattern in the repository.
- `IncludeGrammarPattern`: Includes the base rules of the grammar with a given scope name.

Now whilst there are 4 different patterns, they will all resolve to one or more Rules, and you may have guessed there are actually only two types of rules: `MatchRule` and `BeginEndRule`.

### `MatchRule`
Match a regex on single line of text. Examples:
```Swift
let classRule = MatchRule(name: "keyword.special.class", match: "\\bclass\\b")

let boldRule = MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [])

let italicRule = MatchRule(name: "markup.italic", match: "_.*?_", captures: [])
```

### `BeginEndRule`
Match a begin regex, then try matching it's patterns until the first match of the end regex is found, spanning multiple lines. Example:
```Swift
let swiftString = BeginEndRule(
    name: "string.quoted.double",
    begin: "\"",
    end: "\"",
    patterns: [
        MatchRule(name: "source.swift", match: #"\\\(.*\)"#, captures: [
            Capture(patterns: [IncludeGrammarPattern()])
        ])
    ]
)
```
`BeginEndRule`s also have a `contentName` optional argument, which if provided will apply an additional scope to only the text matched between the begin and end regex matches.

Note the sub-patterns to look for string interpolation and it's captures to recursively include the grammar. But what is a `Capture`? We'll look at that next.


## `Capture`s
When your rules regexes match text (whether it is the MatchRule regex or the two BeginEndRule regexes) you may want to look to apply additional scopes to those matches. A good example is with the bold and italic text `MatchRule` definitions above. You may have noticed they can't be used together to get a bold and italic text token. This is where captures are useful.

Captures take two optional arguments:
```Swift
public init(name: String? = nil, patterns: [Pattern] = [])
```

Use `name` to directly apply the scope to the capture group. Use `patterns` to try and apply more patterns in the capture group.

`Capture`s are applied on the capture group of the index in the array they are defined. Let's take a look at some examples. 


#### MatchRule Captures
Let's use `Capture`s with `MatchRule`s to solve the simultaneously bold and italic problem.

```Swift
let bold = MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [
    Capture(patterns: [
        MatchRule(name: "markup.italic", match: "_.*?_", captures: [])
    ])
])
let italic = MatchRule(name: "markup.italic", match: "_.*?_", captures: [
    Capture(patterns: [
        MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [])
    ])
])
```
Here it's pretty simple, the 0th capture group (the whole regex match) has the `Capture` applied to look for the other rule.

#### BeginEndRule Captures
**NOT YET IMPLEMENTED**

#### Nested Captures
Captures can quickly get a little confusing when there are nested capture groups. Here is an example to see how it is handled.

Say you have a `MatchRule` like so:
```Swift
MatchRule(name: "example", match: "\\+((Hello) (world))\\+", captures: [
    Capture(),
    Capture(name: "Hello world"),
    Capture(name: "Hello"),
    Capture(name: "world")
])
```
Nested capture groups work such that the above "Hello world" capture is applied, then the "Hello", and finally "world". Any scopes added from parent captures will be cascaded onto the nested captures. For example, using the above rule on the following text:

`+Hello world+`

Will produce tokens like:
```
Tokenizing line: +Hello world+

 - Token from 0 to 1 '+' with scopes: [source.test.05, test, ]
 - Token from 1 to 6 'Hello' with scopes: [source.test.05, test, , Hello world, Hello]
 - Token from 6 to 7 ' ' with scopes: [source.test.05, test, , Hello world]
 - Token from 7 to 12 'world' with scopes: [source.test.05, test, , Hello world, world]
 - Token from 12 to 13 '+' with scopes: [source.test.05, test, ]
 - Token from 13 to 14 '
' with scopes: [source.test.05]
```

## `Repository`
The repository is essentially a bank of patterns for a `Grammar`.  Patterns in the repository are referenced by a string key. The repository is really for the sake of clarity and brevity. For example, it makes defining our above italic and bold grammar a lot cleaner. Let's see how:

Original:
```Swift
Grammar(
    scopeName: "source.test.05",
    fileTypes: [],
    patterns: [
        MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [
            Capture(patterns: [
                MatchRule(name: "markup.italic", match: "_.*?_", captures: [])
            ])
        ]),
        MatchRule(name: "markup.italic", match: "_.*?_", captures: [
            Capture(patterns: [
                MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [])
            ])
        ])
    ]
)
```
Using Repository:
```Swift
Grammar(
    scopeName: "source.test.05",
    fileTypes: [],
    patterns: [
        IncludeRulePattern(include: "bold"),
        IncludeRulePattern(include: "italic"),
    ],
    repository: Repository(patterns: [
        "bold": MatchRule(name: "markup.bold", match: "\\*.*?\\*", captures: [
            Capture(patterns: [
                IncludeRulePattern(include: "italic")
            ])
        ]),
        "italic": MatchRule(name: "markup.italic", match: "_.*?_", captures: [
            Capture(patterns: [
                IncludeRulePattern(include: "bold")
            ])
        ])
    ])
)
```

Now obviously for this example, we have more lines of code but we have removed the duplicate concrete pattern (rule) definition. However, it is not too hard to see that as the Grammar grows, it will be beneficial by reducing the duplicate pattern definition like in the original. 

## Themes
The next step in using the `EditorCore` is defining your theme(/s). When we tokenize a piece of text with a grammar we also provide it the desired theme, so that the attributes become associated with the tokens. So what is a theme? A theme is simply just a definition of what attributes should be applied to which scopes. Tokens with multiple scopes (and this will be most of the them) apply scopes in order that they were pushed onto the scope stack. For example, the base grammar scope will be applied first, then the maybe a string scope, then maybe a special token within the string scope.

Create a theme specifying it's name (which isn't too important) and the list of settings, in any order.
```Swift
Theme(name: "basic", settings: [...])
```

The settings are defined like so:
```Swift
ThemeSetting(
    scope: "string.quoted.double",
    parentScopes: [...],
    attributes: [...],
    inSelectionAttributes: [...],
    outSelectionAttributes: [...]
)
```

- `scope` defines the scope that the attributes should be applied to. However, scopes in the tokens do **NOT** have to completely match this scope name. Instead, they only need to match components in this scope. For example, this will match scopes such as `string.quoted.double`, `string.quoted.double.swift` and `string.quoted.double.python` but will not match scopes such as `string.quoted`, `string.quoted.single`, `string.quoted.doublequote`.
- `parentScopes` is **NOT IMPLEMENTED YET**
- `attributes` are the `ThemeAttribute`s to apply to the token regardless. They should implement either `TokenThemeAttribute` or `LineThemeAttribute`. They can affect any of the standard `NSAttributedString` attributes or custom ones. These attributes can safely change the tokens font, paragraph style and attachment attributes as they will be applied prior to a call of `fixAttributes(:)`.
- `inSelectionAttributes` and `outSelectionAttributes` are the attributes to apply to the token when the token is/isn't in a paragraph (line) that is part of the selection or containing the cursor. A call to `fixAttributes(:)` is not always made after applying these attributes so it not safe to modify the font, paragraph style or attachment attributes. These types of attributes were designed for rendering markdown in the textview whenever the line is not being edited. A common attribute to put in these is the `HiddenThemeAttribute` to show/hide syntax characters.

### `ThemeAttribute`s
Finally, what options are there for `ThemeAttributes`. Attributes should implement one of the two available protocols: `TokenThemeAttribute` or `LineThemeAttribute`.

The `TokenThemeAttribute` is designed for adding attributes for the exact range of the token.

The `LineThemeAttribute` is designed for adding paragraph style to line (paragraph) that the token is on. This is split from `TokenThemeAttribute` for efficiency purposes. It is important to note the `LineThemeAttribute`s are applied in order of token, then by increasing specificity of scope. Remember this if you are trying to apply a custom paragraph style for a certain token which isn't the last token on the line, because it could easily be overwritten by a later token.


## Parser
Now that you know how to define a `Grammar` and a `Theme` you need to know how to put them to work.

Create a `Parser` like so, providing all of the grammars that you will need:
```Swift
let parser = Parser(grammars: [...])
```

You will need to provide all grammars that your grammars reference. For example, if you are building a markdown editor, you may have something like the following:
```Swift
let parser = Parser(grammars: [markdownGrammar, swiftGrammar, objCGrammar, pythonGrammar, javaGrammar, htmlGrammar])
```
This is so that when tokenizing, the included grammars (and their patterns) can be resolved.

Now that we have created our parser, we can start tokenizing, like so:
```Swift
let state = markdownGrammar.createFirstLineState(theme: basicTheme)
let tokenizedLine = parser.tokenize(line: "# EditorCore README\n", state: state, withTheme: basicTheme)
```
However, it is unlikely that you will use these methods as `Editor`, `EditorTextStorage`, `EditorLayoutManager` and `EditorTextView` handle all of this for you.



## `EditorUI`
`EditorUI` integrates `EditorCore` into `Cocoa`'s `NSTextView` and  `UIKit`'s `UITextView`. `EditorCore` contains the following:
- `EditorTextStorage` is the implementation of `NSTextStorage` which handles the interaction with `EditorCore`.
- `EditorLayoutManager` is a subclass of `NSLayoutManager` used to implement custom `ThemeAttribute`s.
- `EditorTextView` is a subclass of `NSTextView`/`UITextView` implementing custom features.
- `Editor` is a holds the `EditorTextView` and coordinates all the `Editor` functionality.
- `LineNumberGutter` is an `NSRulerView` for adding line numbers to your `EditorTextView`.
- Default `ThemeAttributes`.

Currently, `EditorTextView` contains more features on macOS. 

### `EditorTextView` [macOS features only]
If you are creating a code editor or just don't want tabs you can indent with spaces instead of tabs:
```Swift
editorTextView.indentUsingSpaces = true
```

You can then define the number of spaces that should be inserted for a tab.
```Swift
editorTextView.tabWidth = 4
```

You may also enable auto indent, to indent the same amount of spaces on the current line when inserting a new line. Currently only this naive auto-indent is supported. There is potential that context-aware indentation is added.
```Swift
editorTextView.autoIndent = true
```

Add line numbers to your editor. You can customize the gutter text color, gutter background color, gutter current line foregroundColor and the gutter width.
```Swift
editorTextView.replace(lineNumberGutter: LineNumberGutter(withTextView: textView))
editorTextView.gutterForegroundColor = .secondaryLabelColor
editorTextView.gutterBackgroundColor = .textBackgroundColor
editorTextView.gutterCurrentLineForegroundColor = .selectedTextColor
editorTextView.gutterWidth = 60
```

### `Editor` [iOS + macOS]
Create an editor like so, where the `baseGrammar` is the grammar that should initialise the state of the tokenization of the text. Remember if the base grammar has included grammars in its definition they should also be registered in the `Parser`!
```Swift
let editor = Editor(textView: textView, parser: parser, baseGrammar: exampleGrammar, theme: exampleTheme)
```

You can later change the `Parser`, base `Grammar` and the `Theme` later:
```Swift
editor.replace(parser: newParser, baseGrammar: newGrammar, theme: newTheme)
```

You can use an `Editor` to receive a list of all full-length (not split up into sub-tokens, with captures) tokens with a given tag, for all scopes that applied with a `MatchRule`. For example, here we receive a list of all the tags (and their ranges) in the text after every edit.
```Swift
editor.subscribe(toToken: "action") { (res) in
    for (str, range) in res {
        print(str, range)
    }
}
```

### `ThemeAttribute`s
There are many predefined `ThemeAttribute`s in `EditorUI` that apply standard `NSAttributedString` attributes:
- `ColorThemeAttribute`
- `DefaultTabIntervalThemeAttribute`
- `FirstLineHeadIndentThemeAttribute`
- `FontThemeAttribute`
- `HeadIndentThemeAttribute`
- `KernThemeAttribute`
- `LigatureThemeAttribute`
- `LineHeightThemeAttribute`
- `ParagraphSpacingAfterThemeAttribute`
- `ParagraphSpacingBeforeThemeAttribute`
- `TabStopsThemeAttribute`
- `TailIndentThemeAttribute`
- `TextAlignmentThemeAttribute`
- `TextBlockThemeAttribute`
- `UndlerlineColorThemeAttribute`

There are also font modifying attributes such as:
- `BoldThemeAttribute` 
- `ItalicThemeAttribute`

Extended default attributes 
- `BackgroundColorThemeAttribute` provides rounded background color functionality.
- `ActionThemeAttribute` adds a handler to link functionality.

Other attributes
- `HiddenThemeAttribute` does not render glyphs formed by characters with this attribute. Useful for hiding syntax.
