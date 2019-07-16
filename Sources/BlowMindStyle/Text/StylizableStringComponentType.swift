import Foundation
import RxSwift

public protocol StylizableStringComponentType {
    associatedtype Style: StyleType
    associatedtype Environment = Void

    func buildAttributedString(
        style: Style,
        environment: Environment,
        getResources: @escaping (Style, Environment) -> Style.Resources)
        -> Observable<NSAttributedString>
}
