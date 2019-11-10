import UIKit
import RxSwift

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

    public init<View: AnyObject>(
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

    public init<View>(
        view: View?,
        getResources: @escaping (Style) -> Observable<(Style.Resources, SemanticStringAttributesProvider)>,
        _ applyStyle: @escaping (View, Style, Style.Resources, NSAttributedString?) -> Void,
        _ storeSubscription: @escaping (Disposable) -> Void
    ) {
        _getResources = getResources

        let storage = Storage(view: view, weak: false)
        _applyStyle = { style, resources, attributedString in
            guard let view = storage.view else { return }
            applyStyle(view, style, resources, attributedString)
        }

        _storeSubscription = storeSubscription
    }

    public func apply(style: Style, text: SemanticString) {
        let subscription = _getResources(style).subscribe(onNext: { [_applyStyle] (resources, provider) in
            _applyStyle(style, resources, text.getAttributedString(provider: provider))
        })

        _storeSubscription(subscription)
    }

    public func apply(style: Style) {
        let subscription = _getResources(style).subscribe(onNext: { [_applyStyle] (resources, _) in
            _applyStyle(style, resources, nil)
        })

        _storeSubscription(subscription)
    }

    public func apply<TextObservable: ObservableConvertibleType>(style: Style, text: TextObservable)
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

extension EnvironmentContext where Element: AnyObject, Element: TraitCollectionProviderType {
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
    public func textStylableElement<Style: SemanticStringStyleType>(
        _ applyStyle: @escaping (Element, Style, Style.Resources, NSAttributedString?) -> Void
    ) -> TextStylableElement<Style>
        where
        Style.Environment == StyleEnvironment
    {
        textStylableElement(EnvironmentChange.LocaleOrThemeOrUserInterfaceStyle.self, applyStyle)
    }
}

extension EnvironmentContext where Element: TraitCollectionProviderType {
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
            getResources: { (style: Style) in filteredEnvironment.resourcesAndProvider(for: style) },
            applyStyle,
            appendSubscription
        )
    }

    public func textStylableElement<Style: SemanticStringStyleType>(
        _ applyStyle: @escaping (Element, Style, Style.Resources, NSAttributedString?) -> Void
    ) -> TextStylableElement<Style>
        where
        Style.Environment == StyleEnvironment
    {
        textStylableElement(EnvironmentChange.Any.self, applyStyle)
    }
}

extension TextStylableElement where Style: DefaultStyleType {
    public func apply() {
        apply(style: .default)
    }

    public func apply(text: SemanticString) {
        apply(style: .default, text: text)
    }

    public func apply<TextObservable: ObservableConvertibleType>(text: TextObservable)
        where TextObservable.Element == SemanticString
    {
        apply(style: .default, text: text)
    }
}
