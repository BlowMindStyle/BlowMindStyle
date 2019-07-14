import RxSwift

public protocol StyleSubscriptionOwnerType {
    func setStyleSubscription(_ disposable: Disposable)
}

public protocol StyleDisposeBagOwnerType: AnyObject, StyleSubscriptionOwnerType {
    var styleDisposeBag: DisposeBag { get set }
}

public extension StyleDisposeBagOwnerType {
    func setStyleSubscription(_ disposable: Disposable) {
        styleDisposeBag = DisposeBag()
        disposable.disposed(by: styleDisposeBag)
    }
}
