import Foundation

public protocol EnvironmentRepeaterType {
    associatedtype Environment
    var environmentRelay: EnvironmentRelay<Environment> { get }
}

private struct AssociatedObjectKeys {
    static var environmentRelay = "environmentRelay"
}

extension EnvironmentRepeaterType where Self: NSObject {
    public var environmentRelay: EnvironmentRelay<Environment> {
        if let existingRelay = objc_getAssociatedObject(self, &AssociatedObjectKeys.environmentRelay) as? EnvironmentRelay<Environment> {
            return existingRelay
        }

        let relay = EnvironmentRelay<Environment>()
        objc_setAssociatedObject(self, &AssociatedObjectKeys.environmentRelay, relay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return relay
    }
}
