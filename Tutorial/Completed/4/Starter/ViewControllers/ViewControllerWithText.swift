import UIKit
import RxSwift
import RxCocoa
import SnapKit
import BlowMindStyle
import SemanticString

final class ViewControllerWithText: UIViewController {
    let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(label)

        label.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private var text: SemanticString {
        SemanticString(xml: """
        <title>Numeric Literals</title>
        Integer literals can be written as:
        <li>•\tA <em>decimal</em> number, with no prefix</li>
        <li>•\tA <em>binary</em> number, with a <code>0b</code> prefix</li>
        <li>•\tAn <em>octal</em> number, with a <code>0o</code> prefix</li>
        <li>•\tA <em>hexadecimal</em> number, with a <code>0x</code> prefix</li>
        """)
    }
}

extension ViewControllerWithText: CompoundStylableElementType {
    typealias Environment = AppEnvironment

    func applyStylesToChildComponents(_ context: Context) {
        context.view.backgroundStyle.apply()
        context.label.textStyle.apply(.article, text: text)
    }
}
