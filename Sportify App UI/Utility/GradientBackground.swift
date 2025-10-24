import UIKit

extension UINavigationBar {
    func setTopGradientColor(topColor: UIColor) {
        var updatedFrame = bounds

        updatedFrame.size.height = 50

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = updatedFrame
        gradientLayer.colors = [topColor.cgColor, topColor.withAlphaComponent(0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
 
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        gradientLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setBackgroundImage(image, for: .default)
        shadowImage = UIImage()
        isTranslucent = true
    }
}
