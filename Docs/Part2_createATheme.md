# 2. Create a theme

In the previous section, we added the primary button style. In this section, we will add the ability to change the theme in the app. The color of the button will depend on the current theme.

> Note: You can find the completed first section project in **Starter_Completed/1** folder.

- Create a theme – add file `AppTheme.swift` and insert:
```
enum AppTheme {
    case theme1
    case theme2
}
```

We need some way to notify components about changing the theme and the ability to change it. Let's create a class for these purposes.

- Add file `AppThemeProvider.swift` and insert:
```
import RxSwift
import RxCocoa

final class AppThemeProvider {
    static let shared = AppThemeProvider()

    private let themeRelay = BehaviorRelay(value: AppTheme.theme1)

    var currentTheme: AppTheme {
        themeRelay.value
    }

    func setCurrentTheme(_ value: AppTheme) {
        themeRelay.accept(value)
    }

    var observableTheme: Observable<AppTheme> {
        themeRelay.asObservable()
    }
}
```

You probably noticed `NoTheme` type argument in line:
```
@Subscription func applyStylesToChildComponents(_ context: EnvironmentContext<ViewController1, StyleEnvironment<NoTheme>>) -> Disposable {
```

- Try to replace `NoTheme` on `AppTheme`.

XCode will show the error:
> Type 'ViewController1' does not conform to protocol 'CompoundStylizableElementType'

The protocol `CompoundStylizableElementType` have associated type `Environment` which must confirm to `StyleEnvironmentConvertible`:
```
public protocol StyleEnvironmentConvertible {
    associatedtype StyleEnvironment: StyleEnvironmentType

    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment
}
```

When the `Environment` is not set the `DefaultStyleEnvironmentConvertible` is used. This struct use `StyleEnvironment<NoTheme>` for associated `StyleEnvironment`. It is why XCode inserts `StyleEnvironment<NoTheme>` in `context` argument. To fix a problem we will add a custom `StyleEnvironmentConvertible` implementation.

- Add file `AppEnvironment.swift` and insert:
```
import UIKit
import BlowMindStyle

struct AppEnvironment {
    let theme: AppTheme

    init(theme: AppTheme) {
        self.theme = theme
    }
}
```

This struct contains the properties on which the UI depends. But styles depends on `UITraitCollection` as well. BlowMindStyle observes `traitCollection` changes and asks `CompoundStylizableElementType.Environment` to create implementation of `StyleEnvironmentType` with passed `traitCollection`. `CompoundStylizableElementType.Environment` must confirm to `StyleEnvironmentConvertible`.

- Add `StyleEnvironmentConvertible` conformance to `AppEnvironment`:
```
extension AppEnvironment: StyleEnvironmentConvertible {
    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment<AppTheme> {
        StyleEnvironment(traitCollection: traitCollection, theme: theme, locale: Locale.current)
    }
}
```

> Note: Here we use default `StyleEnvironment`. If your style depends not only on `UITraitCollection`, `Theme` and `Locale`, you can use a custom type that confirms to `StyleEnvironmentType`.

- Add `typealias Environment = AppEnvironment` into `extension ViewController1`

XCode will show an error because `AppEnvironment` has `AppTheme`, but `context` argument uses `NoTheme`.

- Replace `context` argument type on `Context`:
```
@Subscription func applyStylesToChildComponents(_ context: Context) -> Disposable {
    ...
}
```

`Context` is typealias for `EnvironmentContext<Self, Environment.StyleEnvironment>`. It allows to reduce `applyStylesToChildComponents` method signature and avoid type duplication.

Now we should provide `AppEnvironment` for `ViewController1` stylization.

- In `AppDelegate` replace
`vc.applyStyles()`
on
```
let appEnvironment = AppThemeProvider.shared.observableTheme.map { AppEnvironment(theme: $0) }
vc.applyStyles(for: appEnvironment)
```

- Run the app. The button is still blue.
- Open *Assets.xcassets* and add a new color set that will be used for a button background in the new theme. I added a green color with the name "PrimaryButtonBackgroundGreen", but you can choose the color that you like.

- open *ButtonStyle.swift* and add to the bottom of the file:
```
extension AppTheme {
    var primaryBackgroundColor: UIColor? {
        switch self {
        case .theme1:
            return UIColor(named: "PrimaryButtonBackground")

        case .theme2:
            return UIColor(named: "PrimaryButtonBackgroundGreen")
        }
    }
}
```

- In `ButtonStyle.primary` replace line
```
properties.backgroundColor = env.theme.primaryBackgroundColor?.resolved(with: env.traitCollection
```
on
```
properties.backgroundColor = env.theme.primaryBackgroundColor?.resolved(with: env.traitCollection)
```

XCode will show error:
```
Value of type 'Any' has no member 'resolved'
```

It is because the style doesn't know that we use `AppTheme` for `Theme`. We need to add a constraint on the `Theme` type.
- add constratint `Environment.Theme == AppTheme`:
```
extension ButtonStyle where Environment.Theme == AppTheme {
    ...
}
```

- Run the app. The button is still blue. Initially theme is `.theme1`, we need to add a way to switch the theme. We will add `UISwitch` on the screen.
- Add properties to `ViewController1`:
```
let disposeBag = DisposeBag()

let switchControl = UISwitch()
```

- At the end of `viewDidLoad()` add code:
```
view.addSubview(switchControl)
switchControl.snp.makeConstraints { make in
    make.top.right.equalTo(view.safeAreaLayoutGuide).inset(20)
}

switchControl.rx.isOn.changed.subscribe(onNext: { isOn in
    AppThemeProvider.shared.setCurrentTheme(isOn ? .theme2 : .theme1)
}).disposed(by: disposeBag)
```

- Run the app. Tap on the switch. The button should change the color.

If you want to use different color schemes, you can add the theme to the app. But also themes can help change the visual appearance of visual components completely. Themes can be used for adding support dark appearance on ios 12 and earlier.

You learned how to add a theme to the app. The purpose of the theme is to change appearance throughout the application. But sometimes we need to apply different styles according to some states. How to do this, you will learn in the [next section](Part3_switchStyles.md)