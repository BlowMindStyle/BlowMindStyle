import UIKit

public struct DefaultStyleEnvironment: StyleEnvironmentType {
    public let traitCollection: UITraitCollection

    public init(traitCollection: UITraitCollection = UITraitCollection()) {
        self.traitCollection = traitCollection
    }
}

public struct DefaultStyleEnvironmentConvertible: StyleEnvironmentConvertible {
    public init() { }

    public func toStyleEnvironment(_ traitCollection: UITraitCollection) -> DefaultStyleEnvironment {
        DefaultStyleEnvironment(traitCollection: traitCollection)
    }
}
