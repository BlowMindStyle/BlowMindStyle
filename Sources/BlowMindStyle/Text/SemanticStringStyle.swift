import Foundation
import UIKit
import SemanticString

open class SemanticStringStyle<StyleResources, Environment>: SemanticStringStyleType
    where
    StyleResources: TextAttributesProviderType,
    Environment: StyleEnvironmentType
{
    public typealias Resources = StyleResources

    public typealias SetAttributes = (SemanticString.TextStyle, inout TextAttributes, [SemanticString.TextStyle], Environment) -> Void

    private let _getResources: (Environment) -> StyleResources
    private let _setAttributes: SetAttributes

    public required init(getResources: @escaping (Environment) -> StyleResources, setAttributes: @escaping SetAttributes) {
        _getResources = getResources
        _setAttributes = setAttributes
    }

    public init(
        getResources: @escaping (Environment) -> StyleResources,
        getAttributes: @escaping (SemanticString.TextStyle, Environment) -> TextAttributes
    ) {
        _getResources = getResources
        _setAttributes = { style, attributes, _, env in
            attributes.merge(with: getAttributes(style, env))
        }
    }

    public init(
        getResources: @escaping (Environment) -> StyleResources,
        getAttributes: @escaping (SemanticString.TextStyle, TextAttributes, Environment) -> TextAttributes
    ) {
        _getResources = getResources
        _setAttributes = { style, attributes, _, env in
            attributes.merge(with: getAttributes(style, attributes, env))
        }
    }

    public init(
        getResources: @escaping (Environment) -> StyleResources,
        getAttributes: @escaping (SemanticString.TextStyle, TextAttributes, [SemanticString.TextStyle], Environment) -> TextAttributes
    ) {
        _getResources = getResources
        _setAttributes = { style, attributes, surroundingStyles, env in
            attributes.merge(with: getAttributes(style, attributes, surroundingStyles, env))
        }
    }

    public func getResources(from environment: Environment) -> Resources {
        _getResources(environment)
    }

    public func setAttributes(
        for textStyle: SemanticString.TextStyle,
        attributes: inout TextAttributes,
        surroundingStyles: [SemanticString.TextStyle],
        environment: SemanticStringStyle.Environment
    ) {
        _setAttributes(textStyle, &attributes, surroundingStyles, environment)
    }
}
