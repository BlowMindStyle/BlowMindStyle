import RxSwift
import UIKit

public struct StylableElement<Style: StyleType> {
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

    private let _getResources: (Style) -> Observable<Style.Resources>
    private let _applyStyle: (Style, Style.Resources) -> Void
    private let _storeSubscription: (Disposable) -> Void

    public init<View: AnyObject>(
        view: View?,
        useStrongReference: Bool,
        getResources: @escaping (Style) -> Observable<Style.Resources>,
        _ applyStyle: @escaping (View, Style, Style.Resources) -> Void,
        _ storeSubscription: @escaping (Disposable) -> Void
    ) {
        _getResources = getResources

        let storage = Storage(view: view, weak: !useStrongReference)
        _applyStyle = { style, resources in
            guard let view = storage.view else { return }
            applyStyle(view, style, resources)
        }

        _storeSubscription = storeSubscription
    }

    public init<View>(
        view: View?,
        getResources: @escaping (Style) -> Observable<Style.Resources>,
        _ applyStyle: @escaping (View, Style, Style.Resources) -> Void,
        _ storeSubscription: @escaping (Disposable) -> Void
    ) {
        _getResources = getResources

        let storage = Storage(view: view, weak: false)
        _applyStyle = { style, resources in
            guard let view = storage.view else { return }
            applyStyle(view, style, resources)
        }

        _storeSubscription = storeSubscription
    }

    public func apply(_ style: Style) {
        let subscription = _getResources(style).subscribe(onNext: { [_applyStyle] resources in
            _applyStyle(style, resources)
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
                    return _getResources(style).map { (style, $0) }
            }
            .subscribe(onNext: { [_applyStyle] (style, resources) in
                _applyStyle(style, resources)
            })

            _storeSubscription(subscription)
    }
}

extension EnvironmentContext {
    private func styleEnvironment(with traitCollection: Observable<UITraitCollection>) -> Observable<StyleEnvironment> {
        Observable.combineLatest(environment, traitCollection, resultSelector: { env, traitCollection in
            env.toStyleEnvironment(traitCollection)
        })
    }
}

extension EnvironmentContext where Element: TraitCollectionProviderType {
    func filteredStyleEnvironment<UpdateStrategy: UpdateStyleStrategyType>(_ strategy: UpdateStrategy.Type)
        -> Observable<StyleEnvironment>
        where UpdateStrategy.Environment == StyleEnvironment {
            typealias EnvironmentInfo = (env: StyleEnvironment, skip: Bool)
            let styleEnvironment = self.styleEnvironment(with: element.observableTraitCollection)
            let environmentToSkip = styleEnvironment.scan(Optional<EnvironmentInfo>.none, accumulator: { info, newEnvironment in
                guard let latestStyleUpdateEnvironment = info?.env
                    else { return (newEnvironment, false) }

                let arg = NeedUpdateStyleArgs(
                    latestStyleUpdateEnvironment: latestStyleUpdateEnvironment,
                    newEnvironment: newEnvironment
                )

                if UpdateStrategy.needUpdate(arg) {
                    return (newEnvironment, false)
                } else {
                    return (latestStyleUpdateEnvironment, true)
                }
            })

            return environmentToSkip.filter { $0?.skip == false }.map { $0!.env }
    }
}

extension EnvironmentContext where Element: AnyObject, Element: TraitCollectionProviderType {
    public func stylableElement<Style: EnvironmentStyleType, UpdateStrategy: UpdateStyleStrategyType>(
        _ needUpdateStyleStrategy: UpdateStrategy.Type,
        _ applyStyle: @escaping (Element, Style, Style.Resources) -> Void
    ) -> StylableElement<Style>
        where
        Style.Environment == StyleEnvironment,
        UpdateStrategy.Environment == StyleEnvironment
    {
        let filteredEnvironment = filteredStyleEnvironment(needUpdateStyleStrategy)
        return StylableElement(
            view: element,
            useStrongReference: false,
            getResources: { (style: Style) in filteredEnvironment.map(style.getResources(from:)) },
            applyStyle,
            appendSubscription
        )
    }

    public func stylableElement<Style: EnvironmentStyleType>(
        _ applyStyle: @escaping (Element, Style, Style.Resources) -> Void
    ) -> StylableElement<Style>
        where
        Style.Environment == StyleEnvironment
    {
        stylableElement(EnvironmentChange.Any.self, applyStyle)
    }
}

extension EnvironmentContext where Element: UIView {
    public func stylableElement<Style: EnvironmentStyleType>(
        _ applyStyle: @escaping (Element, Style, Style.Resources) -> Void
    ) -> StylableElement<Style>
        where
        Style.Environment == StyleEnvironment
    {
        stylableElement(EnvironmentChange.ThemeOrUserInterfaceStyle.self, applyStyle)
    }
}

extension EnvironmentContext where Element: TraitCollectionProviderType {
    public func stylableElement<Style: EnvironmentStyleType, UpdateStrategy: UpdateStyleStrategyType>(
        _ needUpdateStyleStrategy: UpdateStrategy.Type,
        _ applyStyle: @escaping (Element, Style, Style.Resources) -> Void
    ) -> StylableElement<Style>
        where
        Style.Environment == StyleEnvironment,
        UpdateStrategy.Environment == StyleEnvironment
    {
        let filteredEnvironment = filteredStyleEnvironment(needUpdateStyleStrategy)
        return StylableElement(
            view: element,
            getResources: { (style: Style) in filteredEnvironment.map(style.getResources(from:)) },
            applyStyle,
            appendSubscription
        )
    }

    public func stylableElement<Style: EnvironmentStyleType>(
        _ applyStyle: @escaping (Element, Style, Style.Resources) -> Void
    ) -> StylableElement<Style>
        where
        Style.Environment == StyleEnvironment
    {
        stylableElement(EnvironmentChange.Any.self, applyStyle)
    }
}

extension StylableElement where Style: DefaultStyleType {
    public func apply() {
        apply(.default)
    }
}
