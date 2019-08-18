import Foundation
import BlowMindStyle

struct MockSemanticStringStyle: SemanticStringStyleType {
    typealias Environment = MockEnvironment

    struct Resources: TextAttributesProviderType {
        var textAttributes: [NSAttributedString.Key: Any] = [:]
    }

    private var resourcesForStyles: [SemanticString.TextStyle: Resources] = [:]

    mutating func setAttributes(_ attributes: [NSAttributedString.Key: Any], for style: SemanticString.TextStyle) {
        resourcesForStyles[style] = Resources(textAttributes: attributes)
    }

    func getResources(from environment: Environment) -> Resources {
        Resources()
    }

    func getResources(from environment: Environment, for textStyle: SemanticString.TextStyle) -> Resources? {
        resourcesForStyles[textStyle]
    }

    static var `default`: MockSemanticStringStyle {
        return .init()
    }
}
