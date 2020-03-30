import Foundation
import SemanticString

/**
 A type that provides attributes for a text.

 This protocol used as a requirement for types specified as `SemanticStringStyle.StyleResources`.
 `textAttributes` used as attributes for a whole text.
 */
public protocol TextAttributesProviderType {
    var textAttributes: TextAttributes { get }
}

/**
 `EnvironmentStyleType` that can provide text attributes for specified text style (SemanticString.TextStyle)
 */
public protocol SemanticStringStyleType: EnvironmentStyleType where Resources: TextAttributesProviderType {
    /**
     updates attributes for specified `textStyle`.

     - SeeAlso: `SemanticString.SemanticStringAttributesProviderType`
     */
    func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle],
        environment: Environment
    )
}
