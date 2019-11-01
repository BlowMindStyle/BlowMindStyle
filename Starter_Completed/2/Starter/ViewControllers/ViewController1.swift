import UIKit
import SnapKit
import BlowMindStyle
import RxSwift

final class ViewController1: UIViewController {
    var styleDisposeBag = DisposeBag()
    let disposeBag = DisposeBag()

    var button = UIButton()
    let switchControl = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        button.setTitle("button", for: .normal)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        view.addSubview(switchControl)
        switchControl.snp.makeConstraints { make in
            make.top.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        switchControl.rx.isOn.changed.subscribe(onNext: { isOn in
            AppThemeProvider.shared.setCurrentTheme(isOn ? .theme2 : .theme1)
        }).disposed(by: disposeBag)
    }
}

extension ViewController1: CompoundStylizableElementType, StyleDisposeBagOwnerType {
    typealias Environment = AppEnvironment

    @Subscription func applyStylesToChildComponents(_ context: Context) -> Disposable {
        context.button.apply(style: .primary)
        context.view.backgroundStyle.apply()
    }
}
