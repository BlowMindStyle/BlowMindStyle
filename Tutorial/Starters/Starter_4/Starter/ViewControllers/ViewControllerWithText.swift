import UIKit
import RxSwift
import RxCocoa
import SnapKit
import BlowMindStyle

final class ViewControllerWithText: UIViewController {
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        label.text = text
        label.numberOfLines = 0

        label.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private var text: String {
        """
        Numeric Literals
        Integer literals can be written as:
        •\tA decimal number, with no prefix
        •\tA binary number, with a 0b prefix
        •\tAn octal number, with a 0o prefix
        •\tA hexadecimal number, with a 0x prefix
        """
    }
}

extension ViewControllerWithText: CompoundStylableElementType {
    typealias Environment = AppEnvironment

    func applyStylesToChildComponents(_ context: Context) {
        context.view.backgroundStyle.apply()
    }
}
