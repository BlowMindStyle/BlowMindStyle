import Foundation
import RxSwift

struct ValueStringConvertible<Value, Style: TextStyleType>: StylizableStringComponentType {
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
