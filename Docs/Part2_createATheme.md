# 2. Create a theme

In the previous section, we added the primary button style. In this section, we will add the ability to change the theme in the app. The color of the button will depend on the current theme.

> Note: You can find the completed first section project in **Starter_Completed/1** folder.

From the previous section, you should know that the default environment type is `DefaultStyleEnvironmentConvertible`. This type doesn't use a theme, so we will create an app-specific theme and environment.

- add file **AppTheme.swift** and insert:
```swift
enum AppTheme {
    case theme1
    case theme2
}
```

- add file **AppEnvironment.swift** and insert:
```swift
import UIKit
import BlowMindStyle

struct AppEnvironment {
    let theme: AppTheme
}

extension AppEnvironment: StyleEnvironmentConvertible {
    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment<AppTheme> {
        StyleEnvironment(traitCollection: traitCollection, theme: theme, locale: locale)
    }
}
```

Open **ViewController1.swift**. To use added `AppEnvironment` we need pass observable with element type conforming to `StyleEnvironmentConvertible`. We don't yet stores current theme, so for simplicity we will use `Observable.just(AppEnvironment(theme: .theme1))`.
- replace `setUpStyles {` on `setUpStyles(with: Observable.just(AppEnvironment(theme: .theme1))) {`

We need some way to notify components about changing the theme and the ability to change it. Let's create a class for these purposes.

- Add file **AppEnvironmentProvider.swift** and insert:
```swift
import RxSwift
import RxCocoa

final class AppEnvironmentProvider {
    static let shared = AppEnvironmentProvider()

    private let themeRelay = BehaviorRelay(value: AppTheme.theme1)

    var currentTheme: AppTheme {
        themeRelay.value
    }

    func setCurrentTheme(_ value: AppTheme) {
        themeRelay.accept(value)
    }

    var observableEnvironment: Observable<AppEnvironment> {
        themeRelay.map { AppEnvironment(theme: $0) }
    }
}
```

Let's add `UISwitch` to toggle theme in `ViewController1`:
- add `switchControl` below `let button = UIButton(type: .custom)`:
```swift
let switchControl = UISwitch()
```
- set up `switchControl`. Add code above `setUpStyles` call.
```swift
view.addSubview(switchControl)
switchControl.snp.makeConstraints { make in
    make.top.right.equalTo(view.safeAreaLayoutGuide).inset(20)
}
```
- add imports of `RxSwift` and `RxCocoa`
- add `disposeBag` below `let switchControl = UISwitch()` to store subscriptions:
```swift
let disposeBag = DisposeBag()
```
- subscribe changing value of `UISwitch` below set up `switchControl`:
```swift
switchControl.rx.isOn.changed.subscribe(onNext: { isOn in
    AppEnvironmentProvider.shared.setCurrentTheme(isOn ? .theme2 : .theme1)
}).disposed(by: disposeBag)
```
- replace `setUpStyles(with: Observable.just(AppEnvironment(theme: .theme1))) {` on
```swift
setUpStyles(with: AppEnvironmentProvider.shared.observableEnvironment) {
```

Our button background color will depends on the theme.
Open **ButtonStyles.swift** and add the constraint to `ButtonStyle` extensions:
```swift
extension ButtonStyle where Environment.Theme == AppTheme {
```
- replace
```swift
properties.backgroundColor = UIColor(named: colorName)
```
on
```swift
let colorName: String = {
    switch env.theme {
    case .theme1:
        return "PrimaryButtonBackground"

    case .theme2:
        return "PrimaryButtonBackground2"
    }
}()

properties.backgroundColor = UIColor(named: colorName)
```

**Note**: After adding the constraint on `Theme` style can be used only when the environment has the same `Theme` type. Next code won't compile:
```swift
setUpStyles {
    $0.button.apply(style: .primary) // error: Static property 'primary' requires the types 'NoTheme' and 'AppTheme' be equivalent
}
```

Add your favorite color named "PrimaryButtonBackground2" to Assets. Run the project and tap on `UISwith`, the button should change color after toggling `UISwitch`.

By now `ViewController1` grabs environment for self from `AppEnvironmentProvider.shared`. It would be better to make responsible for providing the environment the code that presents view controller. This will make it possible to propagate environment through `UIViewController` hierarchy.

- remove
```swift
setUpStyles(with: AppEnvironmentProvider.shared.observableEnvironment) {
    $0.view.backgroundStyle.apply()
    $0.button.apply(style: .primary)
}
```
- add following to end of the file:
```swift
extension ViewController1: CompoundStylableElementType {
    typealias Environment = AppEnvironment

    func applyStylesToChildComponents(_ context: Context) {
        context.view.backgroundStyle.apply()
        context.button.apply(style: .primary)
    }
}
```
`CompoundStylableElementType` protocol says that object can apply styles to its components. `typealias Environment` specifies required environment. `applyStylesToChildComponents(_:)` have argument with type `Context`, it is typealias for `EnvironmentContext`. `applyStylesToChildComponents(_:)` body should be familiar to you.

If you try to build the project you will get compilation error. To fix it make `ViewController1` final:
```swift
final class ViewController1: UIViewController {
```

If you run the project, you will see, that styles were not applied. It is because no one propagates environment to `ViewController1`.

- open **AppDelegate.swift** and add following code after `let vc = ViewController1()`:
```swift
vc.applyStylesOnLoad(for: AppEnvironmentProvider.shared.observableEnvironment)
```

Let's see how to propagate the environment to presented and child controllers. We have only one view controller type and will show it on the button tap.

- add conformance to `EnvironmentRepeaterType` for `ViewController1`:
```swift
extension ViewController1: CompoundStylableElementType, EnvironmentRepeaterType {
```
`EnvironmentRepeaterType` provides the ability to store and repeat the environment. The environment is accessible through `environmentRelay` property.

- add code to the end of `viewDidLoad()`:
```swift
button.rx.tap.subscribe(onNext: { [unowned self] in
    let controller = ViewController1()
    controller.applyStylesOnLoad(for: self.environmentRelay)
    self.show(controller, sender: nil)
}).disposed(by: disposeBag)
```

The created `controller` receive environment from `environmentRelay` and will apply styles after `view` loading.

Run the project. Tap the button. The opened screen should be stylized.

You learned how to add an application theme and propagate the environment.

The application theme can be used to add different color schemes to the app, that change colors of components or completely updates the appearance of visual components. Themes can be used for adding support dark appearance on ios 12 and earlier.

The purpose of the theme is to change appearance throughout the application. But sometimes we need to apply different styles according to some states. How to do this, you will learn in the [next section](Part3_switchStyles.md)

Completed code for current section you can find in **Starter_Completed/2/** folder.