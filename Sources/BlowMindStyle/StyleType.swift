import RxSwift

/**
Base protocol for a style that specifies the type for resources (colors, sizes, fonts, etc.)
 */
public protocol StyleType {
    associatedtype Resources = Void
}

/**
 Style type that requires to have default instance.
 */
public protocol DefaultStyleType: StyleType {
    /**
     The style that will be used if the argument `style` is not specified.

     - SeeAlso: `StylableElement.apply()`
     */
    static var `default`: Self { get }
}
