import UIKit
import RxSwift

public protocol EnvironmentStyleType: StyleType {
    associatedtype Environment: StyleEnvironmentType
    func getResources(from environment: Environment) -> Resources
    func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool
}

public extension EnvironmentStyleType {
    func needUpdate(_ arg: NeedUpdateStyleArgs<Environment>) -> Bool {
        true
    }
}

internal extension EnvironmentStyleType {
    func filteredEnvironment(_ environment: Observable<Environment>) -> Observable<Environment> {
        typealias EnvironmentInfo = (env: Environment, skip: Bool)
        let environmentToSkip = environment.scan(Optional<EnvironmentInfo>.none, accumulator: { info, newEnvironment in
            guard let latestStyleUpdateEnvironment = info?.env
                else { return (newEnvironment, false) }

            let arg = NeedUpdateStyleArgs(
                latestStyleUpdateEnvironment: latestStyleUpdateEnvironment,
                newEnvironment: newEnvironment
            )

            if self.needUpdate(arg) {
                return (newEnvironment, false)
            } else {
                return (latestStyleUpdateEnvironment, true)
            }
        })

        return environmentToSkip.filter { $0?.skip == false }.map { $0!.env }
    }
}
