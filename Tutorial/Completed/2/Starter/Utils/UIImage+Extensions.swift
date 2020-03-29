import UIKit

extension UIImage {
    static func resizableImage(withSolidColor color: UIColor, cornerRadius: CGFloat) -> UIImage {
        precondition(cornerRadius >= 0, "cornerRadius can't be negative")
        let side = cornerRadius * 2 + 1
        let size = CGSize(width: side, height: side)

        let image = UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(color.cgColor)
            let path = CGMutablePath()

            path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: .pi,
                        endAngle: -.pi / 2,
                        clockwise: false)

            path.addLine(to: CGPoint(x: cornerRadius + 1, y: 0))

            path.addArc(center: CGPoint(x: cornerRadius + 1, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: -.pi / 2,
                        endAngle: 0,
                        clockwise: false)

            path.addLine(to: CGPoint(x: side, y: cornerRadius + 1))

            path.addArc(center: CGPoint(x: cornerRadius + 1, y: cornerRadius + 1),
                        radius: cornerRadius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: false)

            path.addLine(to: CGPoint(x: cornerRadius, y: side))

            path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius + 1),
                        radius: cornerRadius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: false)

            path.closeSubpath()

            context.cgContext.addPath(path)
            context.cgContext.fillPath()
        }

        let capInsets = UIEdgeInsets(top: cornerRadius,
                                     left: cornerRadius,
                                     bottom: cornerRadius,
                                     right: cornerRadius)

        let resizableImage = image.resizableImage(withCapInsets: capInsets)

        return resizableImage
    }
}
