import UIKit

public struct NeedUpdateStyleArgs<Environment: StyleEnvironmentType> {
    public let latestStyleUpdateEnvironment: Environment
    public let newEnvironment: Environment

    public init(latestStyleUpdateEnvironment: Environment, newEnvironment: Environment) {
        self.latestStyleUpdateEnvironment = latestStyleUpdateEnvironment
        self.newEnvironment = newEnvironment
    }
}

public extension NeedUpdateStyleArgs {
    func propertyChanged<Property: Equatable>(_ keyPath: KeyPath<Environment, Property>) -> Bool {
        latestStyleUpdateEnvironment[keyPath: keyPath] != newEnvironment[keyPath: keyPath]
    }

    func traitCollectionPropertyChanged<Property: Equatable>(_ keyPath: KeyPath<UITraitCollection, Property>) -> Bool {
        latestStyleUpdateEnvironment.traitCollection[keyPath: keyPath] != newEnvironment.traitCollection[keyPath: keyPath]
    }

    var userInterfaceStyleChanged: Bool {
        if #available(iOS 12, *) {
            return traitCollectionPropertyChanged(\.userInterfaceStyle)
        } else {
            return false
        }
    }

    var userInterfaceLevelChanged: Bool {
        if #available(iOS 13, *) {
            return traitCollectionPropertyChanged(\.userInterfaceLevel)
        } else {
            return false
        }
    }
}
