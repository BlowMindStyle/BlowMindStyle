import Foundation
import SemanticString

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
