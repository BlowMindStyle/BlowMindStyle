import RxSwift
import RxCocoa

final class AppEnvironmentProvider {
    static let shared = AppEnvironmentProvider()

    private let themeRelay = BehaviorRelay(value: AppTheme.theme1)

    var currentTheme: AppTheme {
        themeRelay.value
    }

    func setCurrentTheme(_ value: AppTheme) {
        themeRelay.accept(value)
    }

    var observableEnvironment: Observable<AppEnvironment> {
        themeRelay.map { AppEnvironment(theme: $0) }
    }
}
