import UIKit
import RxSwift

/**
 Style type that can provide style resources for the specified environment.
 */
public protocol EnvironmentStyleType: StyleType {
    associatedtype Environment: StyleEnvironmentType
    func getResources(from environment: Environment) -> Resources
}
