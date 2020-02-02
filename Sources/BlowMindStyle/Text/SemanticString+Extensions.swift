import SemanticString
import Foundation

extension SemanticString {
    public func getAttributedString<Style: SemanticStringStyleType>(
        for style: Style, environment: Style.Environment) -> NSAttributedString {
        getAttributedString(provider: SemanticStringAttributesProvider(style: style, environment: environment))
    }
}
