import UIKit
import BlowMindStyle
import SemanticString

struct TextProperties: TextAttributesProviderType {
    var textAttributes: TextAttributes
    var numberOfLines = 0
}

final class TextStyle<Environment: StyleEnvironmentType>: SemanticStringStyle<TextProperties, Environment> { }

extension EnvironmentContext where Element: UILabel {
    var textStyle: TextStylableElement<TextStyle<StyleEnvironment>> {
        textStylableElement { label, style, resources, string in
            if let string = string {
                label.attributedText = string
            }

            label.numberOfLines = resources.numberOfLines
        }
    }
}
