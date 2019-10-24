import UIKit
import RxSwift
import RxCocoa

public protocol TraitCollectionEnvironmentType {
    var traitCollection: UITraitCollection { get }
}

public struct TraitCollectionEnvironment: TraitCollectionEnvironmentType {
    public let traitCollection: UITraitCollection

    public init(traitCollection: UITraitCollection) {
        self.traitCollection = traitCollection
    }
}

public protocol TraitCollectionProviderType {
    var traitCollectionEnvironment: Observable<TraitCollectionEnvironment> { get }
}

public extension UITraitEnvironment where Self: NSObject {
    var traitCollectionEnvironment: Observable<TraitCollectionEnvironment> {
        .deferred { [weak self] in
            guard let self = self else { return .empty() }

            return self.rx
                .methodInvoked(#selector(UITraitEnvironment.traitCollectionDidChange))
                .map { [unowned self] args in
                    TraitCollectionEnvironment(traitCollection: self.traitCollection)
            }
            .startWith(.init(traitCollection: self.traitCollection))
        }
    }
}

extension UIViewController: TraitCollectionProviderType { }
extension UIView: TraitCollectionProviderType { }
