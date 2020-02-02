import Foundation
import BlowMindStyle
import SemanticString

struct MockSemanticStringStyle: SemanticStringStyleType {
    typealias Environment = MockEnvironment

    struct Resources: TextAttributesProviderType {
        var textAttributes = TextAttributes()
    }

    private var resourcesForStyles: [SemanticString.TextStyle: Resources] = [:]

    func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle],
        environment: Environment
    ) {
        guard let resources = resourcesForStyles[textStyle] else { return }

        for (key, value) in resources.textAttributes.dictionary {
            attributes[key] = value
        }
    }

    mutating func setAttributes(_ attributes: TextAttributes, for style: SemanticString.TextStyle) {
        resourcesForStyles[style] = Resources(textAttributes: attributes)
    }

    func getResources(from environment: Environment) -> Resources {
        Resources()
    }
}
