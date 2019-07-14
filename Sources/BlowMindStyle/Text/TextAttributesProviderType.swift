import Foundation

public protocol TextAttributesProviderType {
    var textAttributes: [NSAttributedString.Key: Any] { get }
}
