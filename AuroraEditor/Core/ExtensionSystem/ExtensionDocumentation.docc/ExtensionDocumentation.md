# ``Aurora Editor`` Extension interface

This is the (internal) documentation of the Aurora Extension Interface.

## Overview

...

## Communication Between Aurora Editor and Extensions

### Received actions for the extension
- didOpen(file: String, contents: String)
- didOpen(workspace: String, file: String, contents: String)
- didSave(file: String)
- didMoveCaret(row: Int, column: Int)
- didActivateTab(file: String)
- didDeactivateTab(file: String)
- didToggleNavigatorPane(visible: Bool)
- didToggleInspectorPane(visible: Bool)
- registerCallback(callback: AuroraAPI -> Bool)
- noop()

### Actions to Aurora Editor
- noop()
- openSettings()
- showNotification(title: String, message: String)
- showWarning(title: String, message: String)
- showError(title: String, message: String)
- openSheet(view: View) // View can be SwiftUI, HTML, (JSON LATER)
- openTab(view: View) // View can be SwiftUI, HTML, (JSON LATER)
- openWindow(view: View) // View can be SwiftUI, HTML, (JSON LATER)

## Demo Swift Extension

```swift
import Foundation
import AEExtensionKit

public class HelloWorldExtension: ExtensionInterface {
    var api: ExtensionAPI
    var AuroraAPI: AuroraAPI = { _, _ in }

    init(api: ExtensionAPI) {
        self.api = api
        print("Hello from HelloWorldExtension: \(api)!")
    }

    public func register() -> ExtensionManifest {
        return .init(
            name: "HelloWorldExtension",
            displayName: "HelloWorldExtension",
            version: "1.0",
            minAEVersion: "1.0"
        )
    }

    public func respond(action: String, parameters: [String: Any]) -> Bool {
        print("respond(action: String, parameters: [String: Any])", action, parameters)

        if action == "registerCallback" {
            if let api = parameters["callback"] as? AuroraAPI {
                AuroraAPI = api
            }
        }

        if action == "didOpen" {
            if let workspace = parameters["workspace"] as? String,
               let file = parameters["file"] as? String {
                print("Opened workspace \(workspace) and file \(file)")
            }
        }

        return true
    }
}

@objc(HelloWorldBuilder)
public class HelloWorldBuilder: ExtensionBuilder {
    public override func build(withAPI api: ExtensionAPI) -> ExtensionInterface {
        return HelloWorldExtension(api: api)
    }
}
```

## Demo JavaScript Extension

```javascript
function didOpen(parameters) {
  AuroraEditor.log(parameters);
}
```
