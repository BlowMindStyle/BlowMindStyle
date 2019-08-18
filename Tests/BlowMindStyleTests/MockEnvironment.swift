import Foundation
import BlowMindStyle

struct MockEnvironment: LocaleEnvironmentType {
    struct LocaleInfo: LocaleInfoType {
        var lprojName: String?
        var locale: Locale
    }

    var localeInfo = LocaleInfo(lprojName: nil, locale: Locale.current)
}
