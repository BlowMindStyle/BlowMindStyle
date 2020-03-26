import UIKit
import SnapKit
import BlowMindStyle

class ViewController1: UIViewController {
    var button = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(button)
        button.setTitle("button", for: .normal)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        setUpStyles {
            $0.view.backgroundStyle.apply()
            $0.button.apply(style: .primary)
        }
    }
}
