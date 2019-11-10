import UIKit
import RxSwift

public protocol EnvironmentStyleType: StyleType {
    associatedtype Environment: StyleEnvironmentType
    func getResources(from environment: Environment) -> Resources
}
