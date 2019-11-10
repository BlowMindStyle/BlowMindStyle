import UIKit
import RxSwift
import RxCocoa

public protocol TraitCollectionProviderType {
    var observableTraitCollection: Observable<UITraitCollection> { get }
}

extension UITraitEnvironment where Self: NSObject {
    public var observableTraitCollection: Observable<UITraitCollection> {
        .deferred { [weak self] in
            guard let self = self else { return .empty() }
            
            return self.rx
                .methodInvoked(#selector(UITraitEnvironment.traitCollectionDidChange))
                .map { [unowned self] args in self.traitCollection }
            .startWith(self.traitCollection)
        }
    }
}

extension UIViewController: TraitCollectionProviderType { }
extension UIView: TraitCollectionProviderType { }
