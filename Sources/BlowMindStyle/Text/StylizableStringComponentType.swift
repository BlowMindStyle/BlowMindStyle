import Foundation
import RxSwift

public protocol StylizableStringComponentType {
    associatedtype Style: EnvironmentStyleType

    func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString>
}
