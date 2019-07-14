import UIKit

struct TextStyles {
    let normal: TextProperties
    let infoTitle: TextProperties
    let infoDescription: TextProperties
    let list: TextProperties
}

protocol TextTheme {
    var textStyles: TextStyles { get }
}

struct TextProperties: BoldFontPropertiesProviderType {
    var fontForBoldText: UIFont = .boldSystemFont(ofSize: 64)
    var paragraphStyle: NSParagraphStyle = NSParagraphStyle()
    var foregroundColor: UIColor?
}

extension TextProperties: TextAttributesProviderType {
    var textAttributes: [NSAttributedString.Key : Any] {
        let attributes: [NSAttributedString.Key: Any?] = [
            .foregroundColor: foregroundColor
        ]

        return attributes.compactMapValues { $0 }
    }
}

enum TextStyle<Theme>: StyleType {
    typealias Properties = TextProperties

    case normal
    case infoTitle
    case infoDescription
    case list

    static var `default`: Self { .normal }
}

extension TextStyle: KeyPathThemeStyleType, ThemeStyleType where Theme: TextTheme {
    var propertiesPath: KeyPath<Theme, TextProperties> {
        switch self {
        case .normal: return \.textStyles.normal
        case .infoTitle: return \.textStyles.infoTitle
        case .infoDescription: return \.textStyles.infoDescription
        case .list: return \.textStyles.list
        }
    }
}

protocol AttributedTextViewType: class {
    func setAttributedText(_ text: NSAttributedString)
}

extension StylizableElements {
    struct Text<Theme, Environment> {
        weak var textView: AttributedTextViewType?
    }
}

extension StylizableElements.Text: StylizableTextElement {
    func apply(style: TextStyle<Theme>,
               properties: TextProperties,
               environment: Environment,
               isInitialApply: Bool,
               text: NSAttributedString) {
        guard let textView = textView else { return }
        textView.setAttributedText(text)
    }
}

extension EnvironmentContext where Element: AttributedTextViewType, Environment: ThemeEnvironmentType, Environment: LocaleEnvironmentType {
    var textStyle: EnvironmentContext<StylizableElements.Text<Environment.Theme, Environment>, Environment> {
        replacingElement(.init(textView: element))
    }
}

extension UILabel: AttributedTextViewType {
    func setAttributedText(_ text: NSAttributedString) {
        attributedText = text
    }
}
