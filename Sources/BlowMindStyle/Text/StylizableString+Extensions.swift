import Foundation

public extension StylizableString {
    func mapAttributedString(_ transform: @escaping (NSAttributedString) -> NSAttributedString) -> Self {
        StylizableString(builder: { style, env in
            self.buildAttributedString(style: style, environment: env).map(transform)
        })
    }
}

public extension StylizableString {
    func uppercased() -> StylizableString {
        mapAttributedString { $0.uppercased() }
    }

    func lowercased() -> StylizableString {
        mapAttributedString { $0.lowercased() }
    }
}

internal extension NSAttributedString {
    func uppercased() -> NSAttributedString {
        transformString { $0.uppercased() }
    }

    func lowercased() -> NSAttributedString {
        transformString { $0.lowercased() }
    }

    func transformString(_ transform: @escaping (String) -> String) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: self)

        result.enumerateAttributes(in: NSRange(location: 0, length: length), options: []) { _, range, _ in
            result.replaceCharacters(in: range, with: transform((string as NSString).substring(with: range)))
        }

        return result
    }
}
