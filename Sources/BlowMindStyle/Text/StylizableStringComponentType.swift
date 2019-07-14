import Foundation
import RxSwift

public protocol StylizableStringComponentType {
    associatedtype Style
    associatedtype Properties

    typealias Locale = String

    func buildAttributedString(
        locale: Locale,
        style: Style,
        propertiesProvider: @escaping (Style) -> Properties)
        -> Observable<NSAttributedString>
}
