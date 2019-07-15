import Foundation
import RxSwift

public protocol StylizableStringComponentType {
    associatedtype Style: StyleType

    typealias Locale = String

    func buildAttributedString(
        locale: Locale,
        style: Style,
        getResources: @escaping (Style) -> Style.Resources)
        -> Observable<NSAttributedString>
}
