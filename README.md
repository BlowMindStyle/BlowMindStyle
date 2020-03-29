![Cocoapods platforms](https://img.shields.io/cocoapods/p/BlowMindStyle.svg)
[![pod](https://img.shields.io/cocoapods/v/BlowMindStyle.svg)](https://cocoapods.org/pods/BlowMindStyle)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

## Introduction

The purpose of the **BlowMindStyle** library is to provide the infrastructure for application styling.
**BlowMindStyle** allows:
- write reusable styles for views
- write reusable styles for text formatting (based on [SemanticString](https://github.com/BlowMindStyle/SemanticString))
- add application themes
- dynamically update views depending on trait collection and theme
- dynamically update views depending on a model state.

## Basic usage

1) Add resources, that will be used for stylization:
```swift
struct ButtonProperties {
    var backgroundColor: UIColor?
    var cornerRadius: CGFloat?
    var titleColor: UIColor?
    var font: UIFont?
    var contentEdgeInsets: UIEdgeInsets?
}
```
2) Define style:
```swift
final class ButtonStyle<Environment: StyleEnvironmentType>: EnvironmentStyle<ButtonProperties, Environment> { }
```

3) Apply resources to view:
```swift
extension EnvironmentContext where Element: UIButton {
    var buttonStyle: StylableElement<ButtonStyle<StyleEnvironment>> {
        stylableElement { button, style, resources in
            button.setTitleColor(resources.titleColor, for: .normal)

            let cornerRadius = resources.cornerRadius ?? 0

            if let normalColor = resources.backgroundColor {
                let normalBackground = UIImage.resizableImage(withSolidColor: normalColor, cornerRadius: cornerRadius)

                button.setBackgroundImage(normalBackground, for: .normal)
            } else {
                button.setBackgroundImage(nil, for: .normal)
            }

            button.titleLabel?.font = resources.font ?? UIFont.systemFont(ofSize: UIFont.buttonFontSize)

            button.contentEdgeInsets = resources.contentEdgeInsets ?? .zero
        }
    }
}
```

4) Use style:
```swift
button.setUpStyles {
    $0.buttonStyle.apply(.primary)
}
```

For more info see [tutorial](#Tutorial)


## Dependencies

* [RxSwift 5](https://github.com/ReactiveX/RxSwift)
* [RxCocoa 5](https://github.com/ReactiveX/RxSwift)
* [SemanticString](https://github.com/BlowMindStyle/SemanticString)

 ## Installation

 ### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

 ```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'BlowMindStyle'
end
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

In XCode select File/Swift Packages/Add Package Dependency. Type 'BlowMindStyle', select `BlowMindStyle` project and click 'Next', 'Next'


## Tutorial

0. [Preparing the project](Tutorial/Docs/Part0_preparingTheProject.md)
1. [Creating your own style](Tutorial/Docs/Part1_createYourOwnStyle.md)
2. [Creating a theme](Tutorial/Docs/Part2_createATheme.md)
3. [Switching styles according to state](Tutorial/Docs/Part3_switchStyles.md)
4. [Text stylization](Tutorial/Docs/Part4_textStylization.md)
