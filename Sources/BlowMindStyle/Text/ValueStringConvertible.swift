import Foundation
import RxSwift

struct ValueStringConvertible<Value, Style: EnvironmentStyleType>: StylizableStringComponentType {
    typealias ConvertToString = (Value, Style, Style.Environment) -> String
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

    func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        valueObservable.map { [convertToString] value in
            NSAttributedString(string: convertToString(value, style, environment))
        }
    }
}

extension ValueStringConvertible where Value: CustomStringConvertible {
    init(value: Value) {
        self = .init(value: value, convertToString: { value, _, _ in  value.description })
    }

    init(valueObservable: Observable<Value>) {
        self = .init(valueObservable: valueObservable, convertToString: { value, _, _ in value.description })
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

public extension StylizableStringArgument {
    static func value<Value: CustomStringConvertible>(_ value: Value) -> Self {
        .init(ValueStringConvertible(value: value))
    }

    static func value<Value>(_ value: Value, with converter: @escaping (Value) -> String) -> Self {
        .init(ValueStringConvertible(value: value, convertToString: { value, _, _ in converter(value) }))
    }

    static func value<Value>(_ value: Value, with converter: @escaping (Value, Style.Environment) -> String) -> Self {
        .init(ValueStringConvertible(value: value, convertToString: { value, _, env in converter(value, env) }))
    }

    static func observable<Value: CustomStringConvertible>(_ observable: Observable<Value>) -> Self {
        .init(ValueStringConvertible(valueObservable: observable))
    }

    static func observable<Value>(_ observable: Observable<Value>, with converter: @escaping (Value) -> String) -> Self {
        .init(ValueStringConvertible(valueObservable: observable, convertToString: { value, _, _ in converter(value) }))
    }

    static func observable<Value>(_ observable: Observable<Value>, with converter: @escaping (Value, Style.Environment) -> String) -> Self {
        .init(ValueStringConvertible(valueObservable: observable, convertToString: { value, _, env in converter(value, env) }))
    }
}
