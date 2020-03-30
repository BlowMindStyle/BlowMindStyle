import SemanticString
import Foundation

extension SemanticString {
    /**
     creates `NSAttributedString` using `SemanticStringStyleType` and environment
     */
    public func getAttributedString<Style: SemanticStringStyleType>(
        for style: Style,
        environment: Style.Environment
    ) -> NSAttributedString {
        getAttributedString(provider: SemanticStringAttributesProvider(style: style, environment: environment))
    }
}
