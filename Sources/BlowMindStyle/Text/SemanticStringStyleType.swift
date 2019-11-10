import Foundation

public protocol TextAttributesProviderType {
    var textAttributes: TextAttributes { get }
}

public protocol SemanticStringStyleType: EnvironmentStyleType where Resources: TextAttributesProviderType {
    func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle],
        environment: Environment
    )
}

public protocol SemanticStringAttributesProviderType {
    var locale: Locale { get }
    func getAttributes() -> TextAttributes
    func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle]
    )
}
