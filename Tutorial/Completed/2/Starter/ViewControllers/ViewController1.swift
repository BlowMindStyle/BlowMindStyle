import UIKit
import SnapKit
import BlowMindStyle
import RxSwift
import RxCocoa

final class ViewController1: UIViewController {
    let button = UIButton(type: .custom)
    let switchControl = UISwitch()
    let disposeBag = DisposeBag()

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
            AppEnvironmentProvider.shared.setCurrentTheme(isOn ? .theme2 : .theme1)
        }).disposed(by: disposeBag)

        button.rx.tap.subscribe(onNext: { [unowned self] in
            let controller = ViewController1()
            controller.applyStylesOnLoad(for: self.environmentRelay)
            self.show(controller, sender: nil)
        }).disposed(by: disposeBag)
    }
}

extension ViewController1: CompoundStylableElementType, EnvironmentRepeaterType {
    typealias Environment = AppEnvironment

    func applyStylesToChildComponents(_ context: Context) {
        context.view.backgroundStyle.apply()
        context.button.apply(style: .primary)
    }
}
