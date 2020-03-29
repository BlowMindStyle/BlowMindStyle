import UIKit
import BlowMindStyle
import SemanticString

extension TextStyle {
    static var article: TextStyle {
        .init(
            getResources: { env in getTextProperties(for: env.traitCollection) },
            setAttributes: { textStyle, attributes, style, env in
                setTextAttributes(forStyle: textStyle, attributes: &attributes, traitCollection: env.traitCollection)
        })
    }
}

private func getTextProperties(for traitCollection: UITraitCollection) -> TextProperties {
    var attributes = TextAttributes()
    attributes.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.paragraphSpacing = UIFontMetrics.default.scaledValue(for: 5, compatibleWith: traitCollection)
    paragraphStyle.lineBreakMode = .byWordWrapping
    attributes.paragraphStyle = paragraphStyle

    return TextProperties(textAttributes: attributes, numberOfLines: 0)
}

private func setTextAttributes(
    forStyle style: SemanticString.TextStyle,
    attributes: inout TextAttributes,
    traitCollection: UITraitCollection) {
    switch style {
    case .title:
        attributes.font = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: traitCollection)
        let paragraphStyle = (attributes.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? .init()
        paragraphStyle.paragraphSpacing = UIFontMetrics.default.scaledValue(for: 14, compatibleWith: traitCollection)
        attributes.paragraphStyle = paragraphStyle

    case .emphasis:
        guard let font = attributes.font else { return }
        var symbolicTraits = font.fontDescriptor.symbolicTraits
        symbolicTraits.insert(.traitItalic)

        guard let descriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) else { return }
        attributes.font = UIFont(descriptor: descriptor, size: font.pointSize)

    case .code:
        if #available(iOS 13.0, *) {
            attributes.foregroundColor = UIColor.secondaryLabel
        } else {
            attributes.foregroundColor = UIColor.gray
        }

        guard let font = attributes.font else { return }
        if #available(iOS 12.0, *) {
            attributes.font = UIFont.monospacedSystemFont(ofSize: font.pointSize, weight: .regular)
        }

    case .listItem:
        let paragraphStyle = (attributes.paragraphStyle?.mutableCopy() as? NSMutableParagraphStyle) ?? .init()
        let listItemTextOffset = UIFontMetrics.default.scaledValue(for: 22, compatibleWith: traitCollection)
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .natural, location: listItemTextOffset)]
        paragraphStyle.paragraphSpacingBefore = UIFontMetrics.default.scaledValue(for: 5, compatibleWith: traitCollection)
        paragraphStyle.headIndent = listItemTextOffset
        paragraphStyle.headIndent = UIFontMetrics.default.scaledValue(for: 10, compatibleWith: traitCollection)
        paragraphStyle.firstLineHeadIndent = UIFontMetrics.default.scaledValue(for: 10, compatibleWith: traitCollection)
        attributes.paragraphStyle = paragraphStyle

    default:
        break
    }
}
