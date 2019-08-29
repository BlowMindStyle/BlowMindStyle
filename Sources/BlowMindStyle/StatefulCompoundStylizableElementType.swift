import UIKit
import RxSwift

public protocol StatefulCompoundStylizableElementType: AnyObject {
    associatedtype Environment
    associatedtype StyleState
    associatedtype ObservableState: ObservableType where ObservableState.E == StyleState

    typealias Context = EnvironmentContext<Self, Environment>

    var observableStyleState: ObservableState { get }

    func applyStylesToChildComponents(_ context: Context, state: StyleState) -> Disposable
}

public extension StatefulCompoundStylizableElementType {
    func applyStyles(for environment: Observable<Environment>) -> Disposable {
        typealias Accumulator = (state: StyleState?, disposeBag: DisposeBag)
        let stateWithDisposeBag = observableStyleState.scan((nil, DisposeBag()) as Accumulator, accumulator: { _, state in
            (state, DisposeBag())
        })

        return stateWithDisposeBag.subscribe(onNext: { [weak self] tuple in
            guard let self = self else { return }

            let context = EnvironmentContext(element: self, environment: environment)
            self.applyStylesToChildComponents(context, state: tuple.state!).disposed(by: tuple.disposeBag)
        })
    }
}

public extension StatefulCompoundStylizableElementType where Self: StyleSubscriptionOwnerType {
    func applyStyles(for environment: Observable<Self.Environment>) {
        setStyleSubscription(applyStyles(for: environment))
    }
}

public extension EnvironmentContext where Element: StatefulCompoundStylizableElementType, Element.Environment == Environment {
    func applyStyles() -> Disposable {
        element.applyStyles(for: environment)
    }
}
