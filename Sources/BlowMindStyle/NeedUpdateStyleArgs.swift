import UIKit

/**
 Argument type that provides previous and new environments for `UpdateStyleStrategyType`
 */
public struct NeedUpdateStyleArgs<Environment: StyleEnvironmentType> {
    public let latestStyleUpdateEnvironment: Environment
    public let newEnvironment: Environment

    public init(latestStyleUpdateEnvironment: Environment, newEnvironment: Environment) {
        self.latestStyleUpdateEnvironment = latestStyleUpdateEnvironment
        self.newEnvironment = newEnvironment
    }
}

extension NeedUpdateStyleArgs {
    /**
     compares specified by `keyPath` property for previous and current environments.
     */
    public func propertyChanged<Property: Equatable>(_ keyPath: KeyPath<Environment, Property>) -> Bool {
        latestStyleUpdateEnvironment[keyPath: keyPath] != newEnvironment[keyPath: keyPath]
    }

    /**
     compares specified by `keyPath` trait collection property for previous and current environments.
     */
    public func traitCollectionPropertyChanged<Property: Equatable>(_ keyPath: KeyPath<UITraitCollection, Property>) -> Bool {
        latestStyleUpdateEnvironment.traitCollection[keyPath: keyPath] != newEnvironment.traitCollection[keyPath: keyPath]
    }

    /**
     detects that user interface style changed
     */
    public var userInterfaceStyleChanged: Bool {
        if #available(iOS 12, *) {
            return traitCollectionPropertyChanged(\.userInterfaceStyle)
        } else {
            return false
        }
    }

    /**
     detects that user interface level changed
     */
    public var userInterfaceLevelChanged: Bool {
        if #available(iOS 13, *) {
            return traitCollectionPropertyChanged(\.userInterfaceLevel)
        } else {
            return false
        }
    }
}
