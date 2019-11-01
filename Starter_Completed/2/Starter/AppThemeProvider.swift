import RxSwift
import RxCocoa

final class AppThemeProvider {
    static let shared = AppThemeProvider()

    private let themeRelay = BehaviorRelay(value: AppTheme.theme1)

    var currentTheme: AppTheme {
        themeRelay.value
    }

    func setCurrentTheme(_ value: AppTheme) {
        themeRelay.accept(value)
    }

    var observableTheme: Observable<AppTheme> {
        themeRelay.asObservable()
    }
}
