import Foundation
import UIKit
import RxSwift

public protocol StyleSubscriptionOwnerType {
    func setStyleSubscription(_ disposable: Disposable)
}

extension StyleSubscriptionOwnerType {
    public func disposeStyleSubscription() {
        setStyleSubscription(Disposables.create())
    }
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

private struct AssociatedObjectKeys {
    static var styleSubscription = "styleSubscription"
}

extension StyleSubscriptionOwnerType where Self: NSObject {
    public func setStyleSubscription(_ disposable: Disposable) {
        let disposeBag = DisposeBag()
        objc_setAssociatedObject(self, &AssociatedObjectKeys.styleSubscription, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        disposeBag.insert(disposable)
    }
}

extension UIViewController: StyleSubscriptionOwnerType { }
extension UIView: StyleSubscriptionOwnerType { }
