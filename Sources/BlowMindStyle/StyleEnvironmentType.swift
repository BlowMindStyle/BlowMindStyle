import UIKit

public protocol StyleEnvironmentType {
    associatedtype Theme = Void

    var traitCollection: UITraitCollection { get }
    var theme: Theme { get }
    var locale: Locale { get }
}

public extension StyleEnvironmentType where Theme == Void {
    var theme: Void { () }
}

public extension StyleEnvironmentType {
    var traitCollection: UITraitCollection { UITraitCollection() }
    var locale: Locale { Locale.current }
}

public protocol StyleEnvironmentConvertible {
    associatedtype StyleEnvironment: StyleEnvironmentType

    func toStyleEnvironment(_ traitCollection: UITraitCollection) -> StyleEnvironment
}
