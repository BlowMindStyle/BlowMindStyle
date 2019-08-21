import UIKit
import RxSwift
import RxCocoa

public protocol TraitCollectionEnvironmentType {
    var traitCollection: UITraitCollection { get }
    var previousTraitCollection: UITraitCollection? { get }
}

public struct TraitCollectionEnvironment: TraitCollectionEnvironmentType {
    public let traitCollection: UITraitCollection
    public let previousTraitCollection: UITraitCollection?

    public init(traitCollection: UITraitCollection,
                previousTraitCollection: UITraitCollection?) {
        self.traitCollection = traitCollection
        self.previousTraitCollection = previousTraitCollection
    }
}

public extension TraitCollectionEnvironmentType {
    func changed<Property: Equatable>(_ keyPath: KeyPath<UITraitCollection, Property>) -> Bool {
        traitCollection[keyPath: keyPath] != previousTraitCollection?[keyPath: keyPath]
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
                .map { [unowned self] args -> TraitCollectionEnvironment in
                    TraitCollectionEnvironment(
                        traitCollection: self.traitCollection,
                        previousTraitCollection: args[0] as? UITraitCollection)
            }
            .startWith(.init(traitCollection: self.traitCollection, previousTraitCollection: nil))
        }
    }
}

extension UIViewController: TraitCollectionProviderType { }
extension UIView: TraitCollectionProviderType { }

@available(iOS 13, *)
public extension TraitCollectionEnvironmentType {
    var styleChanged: Bool {
        changed(\.userInterfaceStyle)
    }

    var levelChanged: Bool {
        changed(\.userInterfaceLevel)
    }
}

public extension TraitCollectionEnvironmentType {
    var horizontalSizeChanged: Bool {
        changed(\.horizontalSizeClass)
    }

    var verticalSizeChanged: Bool {
        changed(\.verticalSizeClass)
    }

    var sizeChanged: Bool {
        horizontalSizeChanged || verticalSizeChanged
    }
}
