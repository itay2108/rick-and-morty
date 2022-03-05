//
//  UIView + Extensions.swift
//  Emotional Aid
//
//  Created by itay gervash on 13/06/2021.
//

import UIKit
import SnapKit
import Darwin
import ImageIO

public extension UIView {
    
    var frameHeight: CGFloat {
        get {
            return self.frame.size.height
        }
    }
    
    var frameWidth: CGFloat {
        get {
            return self.frame.size.width
        }
    }
    
    var widthModifier: CGFloat {
        get {
            return UIScreen.main.bounds.size.height / 812
        }
    }
    
    var heightModifier: CGFloat {
        get {
            return UIScreen.main.bounds.size.width / 375
        }
    }
    
    func circlize() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.height / 2
    }
    
    func uncirclize() {
        
        self.layer.cornerRadius = 0
        self.layer.masksToBounds = true
        
    }
    
    func shadow(color: UIColor, radius: CGFloat, opacity: CGFloat = 0.5, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = Float(opacity)
        self.layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
    }
    
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
     }
    
    func safeAreaSize(from direction: direction) -> CGFloat {
        let insets = UIApplication.shared.windows[0].safeAreaInsets
        let sizeArray = [insets.top, insets.right, insets.bottom, insets.left]
        return sizeArray[direction.rawValue]
    }
    
    func gradientBackground(colors: [CGColor], type: CAGradientLayerType, direction: GradientDirection){
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = colors
        gradient.locations = [ 0.5, 1.0]
        gradient.type = type
        
        switch direction {
        case .leftToRight :
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .topToBottom :
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        case .topLeftToBottomRight :
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        case .topRightToBottomLeft :
            gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        }
        
        gradient.frame = self.bounds
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func fadeIn(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
         self.alpha = 0
         self.isHidden = false
        UIView.animate(withDuration: duration, delay: 0,
                       options: .curveEaseInOut, animations: { self.alpha = 1 },
                        completion: { (value: Bool) in
                           if let complete = onCompletion { complete() }
                        }
         )
     }

     func fadeOut(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
         UIView.animate(withDuration: duration,
                        animations: { self.alpha = 0 },
                        completion: { (value: Bool) in
                            self.isHidden = true
                            if let complete = onCompletion { complete() }
                        }
         )
         
     }
    
}

extension Date {
    func asString(format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func startOfDay() -> Date? {
        let calendar = Calendar.current
        return calendar.dateInterval(of: .day, for: self)?.start
    }
    
    func at(hour: Int) -> Date? {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: self)
    }
    
    var inCurrentTimeZone: Date {
        get {
            let calendar = Calendar(identifier: .gregorian)
            let timezoneSecondOffset = TimeZone.current.secondsFromGMT()
            return calendar.date(byAdding: .second, value: timezoneSecondOffset, to: self) ?? self
        }
    }
}

extension UIViewController {
    
    var emotionalAid: UIApplication {
        return UIApplication.shared
    }
    
    func setupToHideKeyboardOnTapOnView()
        {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(UIViewController.dismissKeyboard))

            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
        }

        @objc func dismissKeyboard()
        {
            self.view.endEditing(true)
        }
    
    var widthModifier: CGFloat {
        get {
            return self.view.frame.width / 375
        }
    }
    
    var heightModifier: CGFloat {
        get {
            return self.view.frame.height / 812
        }
    }
    
    var screenWidth: CGFloat {
        get {
            return self.view.frame.width
        }
    }
    
    var screenHeight: CGFloat {
        get {
            return self.view.frame.height
        }
    }
    
    func safeAreaSize(from direction: direction) -> CGFloat {
        let insets = UIApplication.shared.windows[0].safeAreaInsets
        let sizeArray = [insets.top, insets.right, insets.bottom, insets.left]
        return sizeArray[direction.rawValue]
    }
}

extension UIButton {

    func addTextSpacing(_ letterSpacing: CGFloat){
        if self.titleLabel?.text?.count == nil { self.setTitle("Title", for: .normal)}
        
        let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: letterSpacing, range: NSRange(location: 0, length: (self.titleLabel?.text!.count)!))
        self.setAttributedTitle(attributedString, for: .normal)
    }

}

extension UIStackView {
    func addHorizontalSeparators(with view: UIView) {
            var i = self.arrangedSubviews.count
            while i >= 0 {
                let separator = view
                insertArrangedSubview(separator, at: i)
                separator.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
                i -= 1
            }
        }
}

extension UILabel {
    
    func textSpacing(of spacing: CGFloat) {
        guard self.text != nil else { return }
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, self.text!.count))
        self.attributedText = attributedString
    }
    
    func setLineHeight(lineHeight: CGFloat) {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1.0
            paragraphStyle.lineHeightMultiple = lineHeight
            paragraphStyle.alignment = self.textAlignment

            let attrString = NSMutableAttributedString()
            if (self.attributedText != nil) {
                attrString.append( self.attributedText!)
            } else {
                attrString.append( NSMutableAttributedString(string: self.text!))
                attrString.addAttribute(NSAttributedString.Key.font, value: self.font ?? .systemFont(ofSize: 13), range: NSMakeRange(0, attrString.length))
            }
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            self.attributedText = attrString
        }
    
}

extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if var a = a, var b = b {
            if a < b {
                let c = a
                a = b
                b = c
            }
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
}


extension CGFloat {
    func percentage(_ percent: Int) -> CGFloat {
        return self / 100 * CGFloat(percent)
    }
}

extension CACornerMask {
    static var allCorners: CACornerMask {
        get {
            return [CACornerMask.layerMaxXMaxYCorner, CACornerMask.layerMinXMinYCorner, CACornerMask.layerMinXMaxYCorner, CACornerMask.layerMaxXMinYCorner]
        }
    }
    
    static var topCorners: CACornerMask {
        get {
            return [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner]
        }
    }
    
    static var bottomCorners: CACornerMask {
        get {
            return [CACornerMask.layerMinXMaxYCorner, CACornerMask.layerMaxXMaxYCorner]
        }
    }
}

extension Int {
    func seconds(inComponents components: [timeComponent]) -> [Int] {
        
        var result: [Int] = []
        
        let days = self / 86400
        let hours = (self - (days * 86400)) / 3600
        let minutes = (self - (days * 86400) - (hours * 3600)) / 60
        let seconds = (self - (days * 86400) - (hours * 3600) - (minutes * 60))
        
        for component in components {
            switch component {
            case .day:
                result.append(days)
            case .hour:
                result.append(hours)
            case .minute:
                result.append(minutes)
            case .second:
                result.append(seconds)
            }
        }
        return result
    }
    
    func isPositive() -> Bool {
        let r = self > 0 ? true : false
        return r
    }
    
    func isNegative() -> Bool {
        let r = self < 0 ? true : false
        return r
    }
    
    func positiveValue() -> Int {
        return self > 0 ? self : self * -1
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Array {
    func allElementsAreNil() -> Bool {
        var allNil: Bool = true
        
        for i in (self as [Any?]) {
            if i != nil {
                allNil = false
            }
        }
        
        return allNil
    }
    
    func withoutNilElements() -> [Any] {
        let optionalSelf = self as [Any?]
        var safeSelf: [Any] = []
        
        for element in optionalSelf {
            if let safeElement = element {
                safeSelf.append(safeElement)
            }
        }
        
        return safeSelf
    }
    
}

extension Array where Element == Int {
    func median() -> Double {
        let sortedArray = sorted()
        if count % 2 != 0 {
            return Double(sortedArray[count / 2])
        } else {
            return Double(sortedArray[count / 2] + sortedArray[count / 2 - 1]) / 2.0
        }
    }
}

extension String {
    func containsSpaces() -> Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
    
    func wordCount() -> Int {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        let words = components.filter { !$0.isEmpty }
            
        return words.count
    }
    
    func size( font: UIFont) -> CGSize {
        let fontAttribute = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttribute)  // for Single Line
       return size;
    }
    
    func bareFileFormat() -> String {

        guard let lastSlashIndex = self.lastIndex(of: "/") else { return self }
        let fileStartIndex = self.index(after: lastSlashIndex)
        let newSelf = self[fileStartIndex...]
        
        return String(newSelf)
    }
}

public enum direction: Int {
    case top = 0
    case right = 1
    case bottom = 2
    case left = 3
}

public enum timeComponent {
    case second
    case minute
    case hour
    case day
}

public enum GradientDirection {
    case topToBottom
    case leftToRight
    case topLeftToBottomRight
    case topRightToBottomLeft
}
