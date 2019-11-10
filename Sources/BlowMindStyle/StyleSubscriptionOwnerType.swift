import RxSwift

public protocol StyleSubscriptionOwnerType {
    func setStyleSubscription(_ disposable: Disposable)
}

public protocol StyleDisposeBagOwnerType: AnyObject, StyleSubscriptionOwnerType {
    var styleDisposeBag: DisposeBag { get set }
}

extension StyleDisposeBagOwnerType {
    public func setStyleSubscription(_ disposable: Disposable) {
        styleDisposeBag = DisposeBag()
        disposable.disposed(by: styleDisposeBag)
    }
}
