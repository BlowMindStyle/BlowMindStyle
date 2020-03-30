import Foundation
import UIKit
import RxSwift

/**
 A type that can store style subscription.

 `UIViewController` and `UIView` conform this protocol.
 */
public protocol StyleSubscriptionOwnerType {
    /**
     sets style subscription. The implementation of this method should dispose the previous style subscription.

     - Parameter disposable: style subscription
     */
    func setStyleSubscription(_ disposable: Disposable)
}

extension StyleSubscriptionOwnerType {
    /**
     disposes current style subscription.
     */
    public func disposeStyleSubscription() {
        setStyleSubscription(Disposables.create())
    }
}

/**
 A type that stores style subscription in dispose bag.
 */
public protocol StyleDisposeBagOwnerType: AnyObject, StyleSubscriptionOwnerType {
    /**
     disposeBag that stores current style subscription.
     */
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
