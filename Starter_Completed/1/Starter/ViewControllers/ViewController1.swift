import UIKit
import SnapKit
import BlowMindStyle
import RxSwift

final class ViewController1: UIViewController {
    var styleDisposeBag = DisposeBag()

    var button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        button.setTitle("button", for: .normal)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension ViewController1: CompoundStylizableElementType, StyleDisposeBagOwnerType {
    @Subscription func applyStylesToChildComponents(_ context: EnvironmentContext<ViewController1, StyleEnvironment<NoTheme>>) -> Disposable {
        context.button.apply(style: .primary)
        context.view.backgroundStyle.apply()
    }
}
