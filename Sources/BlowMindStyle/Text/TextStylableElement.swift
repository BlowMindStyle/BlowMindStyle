import UIKit
import RxSwift
import SemanticString

/**
 helps apply text styles in different ways
 */
public struct TextStylableElement<Style: StyleType> {
    private struct Storage<View> {
        private let strongRef: View?
        private weak var weakRef: AnyObject?

        init(view: View?, weak: Bool) {
            if weak {
                weakRef = view as AnyObject
                strongRef = nil
            } else {
                strongRef = view
            }
        }

        var view: View? {
            (weakRef as? View) ?? strongRef
        }
    }

    private let _getResources: (Style) -> Observable<(Style.Resources, SemanticStringAttributesProvider)>
    private let _applyStyle: (Style, Style.Resources, NSAttributedString?) -> Void
    private let _storeSubscription: (Disposable) -> Void

    /**
     - Parameters:
        - view: stylable element
        - useStrongReference: specifies how to store view
        - getResources: the function that provides style resources and the attributes provider
        - applyStyle: the function that applies style resources to the view
        - storeSubscription: the function that stores subscriptions created during applying style.

     - Note: consider using any of `EnvironmentContext.textStylableElement` methods instead of the initializer.
     */
    public init<View>(
        view: View?,
        useStrongReference: Bool,
        getResources: @escaping (Style) -> Observable<(Style.Resources, SemanticStringAttributesProvider)>,
        _ applyStyle: @escaping (View, Style, Style.Resources, NSAttributedString?) -> Void,
        _ storeSubscription: @escaping (Disposable) -> Void
    ) {
        _getResources = getResources

        let storage = Storage(view: view, weak: !useStrongReference)
        _applyStyle = { style, resources, attributedString in
            guard let view = storage.view else { return }
            applyStyle(view, style, resources, attributedString)
        }

        _storeSubscription = storeSubscription
    }

    /**
     applies the style to the view and sets the text.
     */
    public func apply(_ style: Style, text: SemanticString) {
        let subscription = _getResources(style).subscribe(onNext: { [_applyStyle] (resources, provider) in
            _applyStyle(style, resources, text.getAttributedString(provider: provider))
        })

        _storeSubscription(subscription)
    }

    /**
     applies the style to the view without setting a text.
     */
    public func apply(_ style: Style) {
        let subscription = _getResources(style).subscribe(onNext: { [_applyStyle] (resources, _) in
            _applyStyle(style, resources, nil)
        })

        _storeSubscription(subscription)
    }

    /**
     applies the style to the view and sets the observable text.
     */
    public func apply<TextObservable: ObservableConvertibleType>(_ style: Style, text: TextObservable)
        where TextObservable.Element == SemanticString
    {
        let resourcesAndText = Observable.combineLatest(
            _getResources(style),
            text.asObservable(),
            resultSelector: { tuple, text in (tuple.0, tuple.1, text) }
        )

        let subscription = resourcesAndText.subscribe(onNext: { [_applyStyle] resources, provider, text in
            _applyStyle(style, resources, text.getAttributedString(provider: provider))
        })

        _storeSubscription(subscription)
    }

    /**
     gives the ability to select the style that will be applied depending on view or model state.
     */
    public func apply<ObservableState: ObservableConvertibleType, State>(
        forState state: ObservableState,
        _ styleSelector: @escaping (State) -> Style
    )
        where ObservableState.Element == State {
            let subscription = state.asObservable()
                .flatMapLatest { [_getResources] state -> Observable<(Style, Style.Resources)> in
                    let style = styleSelector(state)
                    return _getResources(style).map { (style, $0.0) }
            }
            .subscribe(onNext: { [_applyStyle] (style, resources) in
                _applyStyle(style, resources, nil)
            })

            _storeSubscription(subscription)
    }

    /**
     gives the ability to select the style that will be applied depending on view or model state.
     Sets the specified text.
     */
    public func apply<ObservableState: ObservableConvertibleType, State>(
        forState state: ObservableState,
        text: SemanticString,
        _ styleSelector: @escaping (State) -> Style
    )
        where ObservableState.Element == State {
            let subscription = state.asObservable()
                .flatMapLatest { [_getResources] state -> Observable<(Style, Style.Resources, SemanticStringAttributesProvider)> in
                    let style = styleSelector(state)
                    return _getResources(style).map { (style, $0.0, $0.1) }
            }
            .subscribe(onNext: { [_applyStyle] (style, resources, provider) in
                _applyStyle(style, resources, text.getAttributedString(provider: provider))
            })

            _storeSubscription(subscription)
    }

    /**
     gives the ability to select the style that will be applied depending on view or model state.
     Sets the specified observable text.
     */
    public func apply<ObservableState: ObservableConvertibleType, State, TextObservable: ObservableConvertibleType>(
        forState state: ObservableState,
        text: TextObservable,
        _ styleSelector: @escaping (State) -> Style
    )
        where
        ObservableState.Element == State,
        TextObservable.Element == SemanticString
    {
        let styleAndResources = state.asObservable()
            .flatMapLatest { [_getResources] state -> Observable<(Style, Style.Resources, SemanticStringAttributesProvider)> in
                let style = styleSelector(state)
                return _getResources(style).map { (style, $0.0, $0.1) }
        }

        let styleResourcesAndText = Observable.combineLatest(
            styleAndResources,
            text.asObservable(),
            resultSelector: { tuple, text in (tuple.0, tuple.1, tuple.2, text) }
        )

        let subscription = styleResourcesAndText.subscribe(onNext: { [_applyStyle] (style, resources, provider, text) in
            _applyStyle(style, resources, text.getAttributedString(provider: provider))
        })

        _storeSubscription(subscription)
    }
}

extension Observable where Element: StyleEnvironmentType {
    fileprivate func resourcesAndProvider<Style: SemanticStringStyleType>(for style: Style)
        -> Observable<(Style.Resources, SemanticStringAttributesProvider)>
        where Style.Environment == Element
    {
        map { env in
            let resources = style.getResources(from: env)
            let provider = SemanticStringAttributesProvider(style: style, environment: env)
            return (resources, provider)
        }
    }
}

extension EnvironmentContext where Element: TraitCollectionProviderType {
    /**
     creates `TextStylableElement`

     - Parameters:
        - needUpdateStyleStrategy: the strategy that decides should be the view updated after environment change or not
        - applyStyle: the function that applies style resources and `NSAttributedString` to a view

     - SeeAlso: `UpdateStyleStrategyType`
     */
    public func textStylableElement<Style: SemanticStringStyleType, UpdateStrategy: UpdateStyleStrategyType>(
        _ needUpdateStyleStrategy: UpdateStrategy.Type,
        _ applyStyle: @escaping (Element, Style, Style.Resources, NSAttributedString?) -> Void
    ) -> TextStylableElement<Style>
        where
        Style.Environment == StyleEnvironment,
        UpdateStrategy.Environment == StyleEnvironment
    {
        let filteredEnvironment = filteredStyleEnvironment(needUpdateStyleStrategy)
        return TextStylableElement(
            view: element,
            useStrongReference: false,
            getResources: { (style: Style) in filteredEnvironment.resourcesAndProvider(for: style) },
            applyStyle,
            appendSubscription
        )
    }

    /**
    creates `TextStylableElement`. The view will be updated after any environment change.

    - Parameters:
       - applyStyle: the function that applies style resources and `NSAttributedString` to a view
    */
    public func textStylableElement<Style: SemanticStringStyleType>(
        _ applyStyle: @escaping (Element, Style, Style.Resources, NSAttributedString?) -> Void
    ) -> TextStylableElement<Style>
        where
        Style.Environment == StyleEnvironment
    {
        textStylableElement(EnvironmentChange.Any.self, applyStyle)
    }
}

extension EnvironmentContext where Element: UIView {
    /**
    creates `TextStylableElement`. The view will be updated when the locale or the theme or user interface style changed.

    - Parameters:
       - applyStyle: the function that applies style resources and `NSAttributedString` to a view
    */
    public func textStylableElement<Style: SemanticStringStyleType>(
        _ applyStyle: @escaping (Element, Style, Style.Resources, NSAttributedString?) -> Void
    ) -> TextStylableElement<Style>
        where
        Style.Environment == StyleEnvironment
    {
        textStylableElement(EnvironmentChange.LocaleOrThemeOrUserInterfaceStyle.self, applyStyle)
    }
}

extension TextStylableElement where Style: DefaultStyleType {
    /**
     applies default style
     */
    public func apply() {
        apply(.default)
    }

    /**
     applies default style and sets the specified text
     */
    public func apply(text: SemanticString) {
        apply(.default, text: text)
    }

    /**
     applies default style and sets the specified observable text
     */
    public func apply<TextObservable: ObservableConvertibleType>(text: TextObservable)
        where TextObservable.Element == SemanticString
    {
        apply(.default, text: text)
    }
}
