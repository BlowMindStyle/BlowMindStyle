# 3. Switch styles according to state

Sometimes we need to change styles for view dynamically depending on some state. In this section, we will add a new button style and add switching the style after changing the value of switch control.

> Note: We will use code from previous section. You can find completed solution in **Starter_Completed/2** folder.

By now we have only one button style. Let's add another one.

- Open `ButtonStyles.swift` and add code to `ButtonStyle` extension:
```
static var simple: Self {
    .init { env in
        var properties = ButtonProperties()
        properties.titleColor = env.theme.primaryBackgroundColor
        properties.highlightedTitleColor = env.theme.primaryBackgroundColor?.withAlphaComponent(0.5)
        return properties
    }
}
```

A button with applied `simple` style will be without background and title color like the background of the primary button.
`ButtonProperties` does not contain `highlightedTitleColor` property. Let's add it.
- Open `ButtonStyle.swift` and add line
```
public var highlightedTitleColor: UIColor?
```
after `public var titleColor: UIColor?` in `ButtonProperties`.

- Add
```
button.setTitleColor(resources.highlightedTitleColor, for: .highlighted)
```
 after `button.setTitleColor(resources.titleColor, for: .normal)` in `StylizableElements.Button.apply` method.


- Add property
```
let stateSubject = BehaviorSubject(value: false)`
```
to `ViewController1`.

When state == true we will apply `primary` style, and `simple` otherwise. But before we let's and another UISwitch in bind `isOn` value to `stateSubject`.

- Add code at the end of `viewDidLoad()`:
```
let switchControl2 = UISwitch()
view.addSubview(switchControl2)
switchControl2.snp.makeConstraints { make in
    make.trailing.equalTo(switchControl)
    make.top.equalTo(switchControl.snp.bottom).offset(20)
}

switchControl2.rx.isOn.subscribe(stateSubject).disposed(by: disposeBag)
```

And the final step.
- Replace `context.button.apply(style: .primary)`
on
```
context.button.buttonStyle.apply(forState: stateSubject) { state in
    state ? .primary : .simple
}
```

The method `apply(forState state:, _)` takes two arguments: first - observable state confirming to `ObservableConvertibleType` and second – function that returns appropriate style for received state.

- Run the project and tap on the second switch. The button should change the style. Tap on the first switch to make sure that the button style still depends on the app theme.

[Next section](Part4_textStylization.md)