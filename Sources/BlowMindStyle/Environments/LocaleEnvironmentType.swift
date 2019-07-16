import Foundation

public protocol LocaleType {
    var lprojName: String { get }
}

public protocol LocaleEnvironmentType {
    associatedtype Locale: LocaleType
    var locale: Locale { get }
}

