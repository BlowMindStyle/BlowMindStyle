public enum OptionalStyleValue<Value> {
    case some(Value)
    case notSet
    case setNil
}

extension OptionalStyleValue {
    public init(setValue value: Value?) {
        switch value {
        case let .some(value):
            self = .some(value)

        case .none:
            self = .setNil
        }
    }
}

public extension OptionalStyleValue {
    func set(_ apply: (Value?) -> Void) {
        switch self {
        case let .some(value):
            apply(value)

        case .setNil:
            apply(nil)

        case .notSet:
            return
        }
    }
}
