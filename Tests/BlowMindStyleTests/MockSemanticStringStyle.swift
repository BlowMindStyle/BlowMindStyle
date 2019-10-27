import Foundation
import BlowMindStyle

struct MockSemanticStringStyle: SemanticStringStyleType {
    typealias Environment = MockEnvironment

    struct Resources: TextAttributesProviderType {
        var textAttributes: [NSAttributedString.Key: Any] = [:]
    }

    private var resourcesForStyles: [SemanticString.TextStyle: Resources] = [:]

    func setAttributes(for textStyle: SemanticString.TextStyle, attributes: inout [NSAttributedString.Key : Any], surroundingStyles: [SemanticString.TextStyle], environment: MockEnvironment) {
        guard let resources = resourcesForStyles[textStyle] else { return }

        for (key, value) in resources.textAttributes {
            attributes[key] = value
        }
    }

    mutating func setAttributes(_ attributes: [NSAttributedString.Key: Any], for style: SemanticString.TextStyle) {
        resourcesForStyles[style] = Resources(textAttributes: attributes)
    }

    func getResources(from environment: Environment) -> Resources {
        Resources()
    }
}
