import UIKit
import SnapKit

class ViewController1: UIViewController {
    var button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        view.addSubview(button)
        button.setTitle("button", for: .normal)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
