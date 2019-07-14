import Foundation

public struct StringResource: StringResourceType {
    /// Key for the string
    public let key: String

    /// File in containing the string
    public let tableName: String

    /// Bundle this string is in
    public let bundle: Bundle
}
