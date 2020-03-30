import RxSwift

extension Disposable {
    /**
     stores subscription in style subscriptions
     */
    public func disposed<Element, Environment>(by context: EnvironmentContext<Element, Environment>) {
        context.appendSubscription(self)
    }
}
