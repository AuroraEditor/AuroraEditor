Usage:

``` swift
Log.trace("Opened a file")
Log.debug("Check here for debugging")
Log.info("Oh look the editor opened a file at this location: ")
Log.warning("Be careful looks like this line can cause memory leaks.")
Log.error("Well that didn't go as expected!")
```
Output:
```
[2022-08-04 15:36:19.361] WorkspaceCodeFileView.swift:27 INFO: Item loaded is: file:///Users/tihan-nico/Documents/GitHub/CodeEdit/CodeEdit/CodeEdit.entitlements
```

### Min level of logs that will be shown:
``` swift
Log.minLogLevel = .warning
```
