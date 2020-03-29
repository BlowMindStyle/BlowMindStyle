# 0. Preparing the project

The repository contains the project `Starter` for which tutorial was written. The project has 3 dependencies:
- local `BlowMindStyle` swift package
- remote `SnapKit` swift package for convinient UI layout
- `R.swift` pod for generating strong typed access to string resources

and
- `RxSwift` + `RxCocoa`

on which `BlowMindStyle` depends.

`SnapKit`, `RxSwift` and `RxCocoa` will be automatically downloaded by XCode. For installing `R.swift` open `Starter` folder in the terminal and type:
```
> pod install
```

(you need installed [CocoaPods](https://cocoapods.org))

[Next section](Part1_createYourOwnStyle.md)