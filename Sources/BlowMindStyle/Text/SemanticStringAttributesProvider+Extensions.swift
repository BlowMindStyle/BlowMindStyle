import SemanticString

extension SemanticStringAttributesProvider {
    public init<Style: SemanticStringStyleType>(style: Style, environment: Style.Environment) {
        self = .init(
            locale: environment.locale,
            getAttributes: { style.getResources(from: environment).textAttributes },
            setAttributes: { textStyle, attributes, otherStyles in
                style.setAttributes(for: textStyle, attributes: &attributes, surroundingStyles: otherStyles, environment: environment)
        })
    }
}
