import RxSwift

extension Disposable {
    public func disposed<Element, Environment>(by context: EnvironmentContext<Element, Environment>) {
        context.appendSubscription(self)
    }
}
