# nconsole

A library for show log in console. CocoaPod Specs for iOS/macOS.

## Getting Started

![Demo NConsole](https://github.com/nghinv-software/nconsole-ios/blob/main/demo_nconsole.png)

## Installation

App desktop download [NConsole](https://drive.google.com/drive/folders/1P4cqXhalzsiPtrVAKWvoD9tK_pt9ZpzJ?usp=share_link)

```sh
pod 'NConsole', '=1.0.1'
```

## Usages

```swift
import NConsole

let dataTest = DataTest(name: "Thanh", old: 22, className: 11)
NConsole.isEnable = true

NConsole.log("Data::", dataTest)
NConsole.log("Hello")
NConsole.groupCollapsed("Hi, how are you?")
NConsole.log("Data:", dataTest)
NConsole.groupEnd()
```

## Note

- Need to set `ENABLE_USER_SCRIPT_SANDBOXING = NO` in `VS CODE` to run the app on the simulator.

GO to the VS CODE => SEARCH(Command +shift + f) => ENABLE_USER_SCRIPT_SANDBOXING = NO;
