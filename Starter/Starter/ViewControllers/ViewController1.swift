import UIKit
import SnapKit

final class ViewController1: UIViewController {
    var button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(button)
        button.setTitle("button", for: .normal)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
