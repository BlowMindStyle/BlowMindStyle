import Foundation
import RxSwift

struct StringResourceFormatter<Style: TextStyleType>: StylizableStringComponentType
where Style.Environment: LocaleEnvironmentType {
    let resource: StringResourceType
    private let args: Observable<[CVarArg]>

    init(resource: StringResourceType, args: [Observable<CVarArg>]) {
        self.resource = resource

        if args.isEmpty {
            self.args = .just([])
        } else {
            self.args = Observable.combineLatest(args)
        }
    }

    func buildAttributedString(style: Style, environment: Style.Environment) -> Observable<NSAttributedString> {
        let format = environment.localeInfo.localize(resource)
        return args.map { args in
            let string = String(format: format, arguments: args)
            return NSAttributedString(string: string)
        }
    }
}

public extension StylizableString.StringInterpolation where Style.Environment: LocaleEnvironmentType {
    mutating func appendInterpolation(resource: StringResourceType?, args: Observable<CVarArg>...) {
        guard let resource = resource else { return }

        appendComponent(StringResourceFormatter(resource: resource, args: args))
    }
}
