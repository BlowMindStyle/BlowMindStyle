import Foundation

public protocol StringResourceType {
    /// Key for the string
    var key: String { get }

    /// File in containing the string
    var tableName: String { get }

    /// Bundle this string is in
    var bundle: Bundle { get }
}
