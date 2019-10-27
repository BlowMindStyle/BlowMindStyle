import RxSwift

public protocol StyleType {
    associatedtype Resources = Void
}

public protocol DefaultStyleType: StyleType {
    static var `default`: Self { get }
}
