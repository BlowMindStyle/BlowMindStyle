import Foundation
import RxSwift

public protocol StylizableStringComponentType {
    associatedtype Style: TextStyleType

    func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString>
}
