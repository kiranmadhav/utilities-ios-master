
import UIKit

extension UILabel {
    static func attributedString(fromHTML html: String, withTextSize textSize: CGFloat) -> NSAttributedString? {
        let str = html.replacingOccurrences(of: "\n", with: "<br />")

        let modifiedFont = "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(textSize)px\">\(str)</span>"

        guard let htmlData = modifiedFont.data(using: .unicode, allowLossyConversion: true) else { return nil }

        return try? NSAttributedString(
            data: htmlData,
            options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
    }
    
    func setHTMLFromString(htmlText: String) {
        if let attributedString = UILabel.attributedString(fromHTML: htmlText, withTextSize: font.pointSize) {
            let mutableString = NSMutableAttributedString(attributedString: attributedString)

            // strings surrounded in <p> tags add a line break. We need to remove it
            if mutableString.string.hasSuffix("\n") {
                mutableString.replaceCharacters(in: NSRange(location: mutableString.length - 1, length: 1), with: "")
            }

            self.attributedText = mutableString
        } else {
            self.text = htmlText.stringWithHTMLtagsStripped()
        }
    }
}
