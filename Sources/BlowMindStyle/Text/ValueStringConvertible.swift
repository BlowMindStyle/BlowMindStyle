import Foundation
import RxSwift

struct ValueStringConvertible<Value, Style: StyleType>: StylizableStringComponentType {
    typealias ConvertToString = (Value, Self.Locale, Style, (Style) -> Style.Resources) -> String
    private let valueObservable: Observable<Value>
    private let convertToString: ConvertToString

    init(value: Value, convertToString: @escaping ConvertToString) {
        valueObservable = .just(value)
        self.convertToString = convertToString
    }

    init(valueObservable: Observable<Value>, convertToString: @escaping ConvertToString) {
        self.valueObservable = valueObservable
        self.convertToString = convertToString
    }

    func buildAttributedString(locale: String, style: Style, getResources: @escaping (Style) -> Style.Resources) -> Observable<NSAttributedString> {
        valueObservable.map { [convertToString] value in
            NSAttributedString(string: convertToString(value, locale, style, getResources))
        }
    }
}

extension ValueStringConvertible where Value: CustomStringConvertible {
    init(value: Value) {
        self = .init(value: value, convertToString: { value, _, _, _ in  value.description })
    }

    init(valueObservable: Observable<Value>) {
        self = .init(valueObservable: valueObservable, convertToString: { value, _, _, _ in value.description })
    }
}

public extension StylizableString.StringInterpolation {
    mutating func appendInterpolation<Value: CustomStringConvertible>(_ value: Value) {
        appendComponent(ValueStringConvertible(value: value))
    }

    mutating func appendInterpolation<Value: CustomStringConvertible>(_ observable: Observable<Value>) {
        appendComponent(ValueStringConvertible(valueObservable: observable.asObservable()))
    }
}

extension StylizableStringArgument {
    static func value<Value: CustomStringConvertible>(_ value: Value) -> Self {
        .init(ValueStringConvertible(value: value))
    }

    static func value<Value>(_ value: Value, with converter: @escaping (Value) -> String) -> Self {
        .init(ValueStringConvertible(value: value, convertToString: { value, _, _, _ in converter(value) }))
    }

    static func value<Value>(_ value: Value, with converter: @escaping (Value, _ locale: String) -> String) -> Self {
        .init(ValueStringConvertible(value: value, convertToString: { value, locale, _, _ in converter(value, locale) }))
    }

    static func observable<Value: CustomStringConvertible>(_ observable: Observable<Value>) -> Self {
        .init(ValueStringConvertible(valueObservable: observable))
    }

    static func observable<Value>(_ observable: Observable<Value>, with converter: @escaping (Value) -> String) -> Self {
        .init(ValueStringConvertible(valueObservable: observable, convertToString: { value, _, _, _ in converter(value) }))
    }

    static func observable<Value>(_ observable: Observable<Value>, with converter: @escaping (Value, _ locale: String) -> String) -> Self {
        .init(ValueStringConvertible(valueObservable: observable, convertToString: { value, locale, _, _ in converter(value, locale) }))
    }
}
