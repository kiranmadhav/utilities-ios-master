//
//  HTMLLabel.swift
//  Utilities
//  originated as:
//  MathLabel.swift
//  StudyWiseKit
//
//  Created by Brooks, Jon on 2/6/18.
//  Copyright © 2018 mhe. All rights reserved.
//

import Foundation
import WebKit

private extension UIColor {
    var cssString: String {

        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(1)

        getRed(&r, green: &g, blue: &b, alpha: &a)

        func toInt(_ float: CGFloat) -> Int {
            return Int(ceil(float * 255))
        }
        return "rgba(\(toInt(r)),\(toInt(g)),\(toInt(b)),\(a))"

    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
}

extension NSTextAlignment {
    var cssFlexString: String {
        switch self {
        case .left:
            return "flex-start"
        case .right:
            return "flex-end"
        case .center:
            return "center"
        case .justified:
            return "justify"
        default:
            return "flex-start"
        }
    }
}

open class HTMLLabel: UIView {

    public var headContent = ""

    //CSS for spans that will be read by accessibility, but be visually hidden
    //Stolen from AIR codebase
    private let hiddenCSS = """
        ._visuallyHidden {
            border: 0;
            clip: rect(0 0 0 0);
            height: 1px;
            margin: -1px;
            overflow: hidden;
            padding: 0;
            position: absolute;
            width: 1px;
        }
        """

    private let mathJaxURL = WebServer.resourcesCDN?.withAppendedURLString(
        "/js/vendor/mathjax/MathJax.js?config=MML_SVG"
    )

    private let musicRenderingURL = WebServer.resourcesCDN?.withAppendedURLString(
        "/js/vendor/music-rendering/render.mobile.min.js"
    )

    //We always create a label under the hood.  In non-math context, this label is all thats ever used
    //In math contexts, we still use the label for initial sizing of the view until the webview is ready
    public var forceWebviewRendering: Bool = false
    public var allowInteractionWithWebview: Bool = false

    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isOpaque = false
        label.backgroundColor = .clear
        label.numberOfLines = 0
        addSubview(label)
        label.constrainToSuperviewEdges()

        return label
    }()

    private let handlerID = "htmlLabel"
    private let contentController = WKUserContentController()

    //The webview is created on demand, only when there is MathML in the content
    public private(set) lazy var webview: WKWebView  = {
        contentController.add(self, name: handlerID)
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.suppressesIncrementalRendering = true
        let webview = WKWebView(frame: .zero, configuration: config)

        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.isHidden = true
        webview.scrollView.bounces = false
        addSubview(webview)
        webview.constrainToSuperviewEdges()
        isUserInteractionEnabled = false

        if allowInteractionWithWebview {
            isUserInteractionEnabled = true
        }

        self.observation = webview.scrollView.observe(\UIScrollView.contentSize) { [weak self] (_, _) in
            self?.recalculateContentSize()
        }

        return webview
    }()

    public var wkwebview: WKWebView? {
        return webview
    }

    deinit {
        contentController.removeScriptMessageHandler(forName: handlerID)
    }

    private func generateAccessibilityElements() {
        accessibilityElements = shouldRenderInWebview ? [webview] : [label]
    }

    let blankPlaceholder = "_BLANK_"

    var contentHasBlankPlaceholder: Bool {
        return content?.range(of: blankPlaceholder, options: .caseInsensitive) != nil
    }

    var contentWithPlaceholderReplaced: String? {
        guard let content = content else {
            return nil
        }

        return content.replacingOccurrences(of: blankPlaceholder, with: """
                <span class="_visuallyHidden">blank</span><span aria-hidden="true">______</span>
                """, options: .caseInsensitive)
    }

    // MARK: Public properties

    //arbitrary HTML content to be displayed, that may or may not include MathML
    //This implementation assumes content will be set once.  It would be easy to support setting it
    //multiple times, but assuming a single set was sufficient for our needs.  Currently, the label
    //view gets removed from the view hierarchy once the webview is ready, so it would need to get
    //readded, and the `calculatedWebContentHeight` would also need to be reset.  Possibly the webview
    //should get torn down too.
    public var content: String? {
        didSet {
            calculatedWebContentHeight = nil

            //Somewhat delicate here: we can query `isShowingWebview` without lazy loading the webview
            //but setting isShowingWebview to anything will lazy load it.  We want to be careful not to
            //load the webview if we don't have to
            if isShowingWebview {
                isShowingWebview = false
            }

            label.setHTMLFromString(htmlText: contentWithMathAndTablesStripped ?? "")
            if content != oldValue {
                requestRerender()
            }
            generateAccessibilityElements()
        }
    }

    public var font: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            label.font = font
            if font != oldValue {
                requestRerender()
            }
        }
    }

    public var textColor: UIColor = .black {
        didSet {
            label.textColor = textColor
            if textColor != oldValue {
                requestRerender()
                //  The below avoids a rerender, but in iOS 13, it causes the keyboard to not appear for FIB probes for some reason.
                //  webview.evaluateJavaScript("document.getElementById('content').style.color = '\(textColor.cssString)'")
            }
        }
    }

    public var textAlignment: NSTextAlignment  = .left {
        didSet {
            label.textAlignment = textAlignment
            if textAlignment != oldValue {
                requestRerender()
            }
        }
    }

    public override var intrinsicContentSize: CGSize {
        if let contentHeight = calculatedWebContentHeight, isShowingWebview {
            return CGSize(width: webview.scrollView.contentSize.width, height: contentHeight)
        } else {
            return label.intrinsicContentSize
        }
    }

    open var contentHasMath: Bool {
        return (content?.range(of: "<math") != nil)
    }

    open var contentHasLists: Bool {
        return (content?.range(of: "<ol") != nil || content?.range(of: "<ul") != nil ||  content?.range(of: "<li") != nil)
    }

    open var contentHasTables: Bool {
        return (content?.range(of: "<table") != nil)
    }

    open var contentHasMHESymbols: Bool {
        return (content?.range(of: "<mhe-symbol") != nil)
    }

    // MARK: Private properties
    private var shouldRenderInWebview: Bool {
        return forceWebviewRendering || contentHasMath || contentHasTables || contentHasMHESymbols || contentHasLists || contentHasBlankPlaceholder
    }

    //We get better estimated sizes by stripping the math when putting it in the label
    private var contentWithMathAndTablesStripped: String? {
        guard
            let content = content,
            let mathRegex = try? NSRegularExpression(pattern: "<math.*?math>"),
            let tableRegex = try? NSRegularExpression(pattern: "<table.*?table>"),
            let mheSymbolRegex = try? NSRegularExpression(pattern: "<mhe-symbol.*?mhe-symbol>")
        else {
            return nil
        }

        let mutable = NSMutableString(string: content)

        mathRegex.replaceMatches(in: mutable, range: NSRange(location: 0, length: (mutable as String).count), withTemplate: "     ")
        tableRegex.replaceMatches(in: mutable, range: NSRange(location: 0, length: (mutable as String).count), withTemplate: "     ")
        mheSymbolRegex.replaceMatches(in: mutable, range: NSRange(location: 0, length: (mutable as String).count), withTemplate: "     ")
        mutable.replaceOccurrences(of: blankPlaceholder, with: "______", options: .caseInsensitive, range: NSRange(location: 0, length: (mutable as String).count))

        return mutable as String
    }

    //This observation monitors the webview's scrollView's content size property
    private var observation: NSKeyValueObservation?

    //This gets set once the webview has reported an accurate size for its content.  If nil,
    //we are either using a UILabel entirely, or using it temporarily until the webview renders
    private var calculatedWebContentHeight: CGFloat?

    private var needsRerender = false

    //Rather than rerender immediately, we set a flag and queue a rerender, so that clients
    //who are setting a bunch of properties that require rerender all at once don't trigger
    //multiple rerenders
    public func requestRerender() {
        needsRerender = true

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.needsRerender {
                if strongSelf.shouldRenderInWebview {
                    strongSelf.webview.loadHTMLString(strongSelf.htmlDocument, baseURL: nil)
                }
            }

            strongSelf.needsRerender = false

        }
    }
}

// MARK: - Webview implementation
extension HTMLLabel {
    private var musicRenderingElements: String {
        guard contentHasMHESymbols, let musicRenderingURLString = musicRenderingURL?.absoluteString else {
            return ""
        }

        return """
        <script type='text/javascript' src='\(musicRenderingURLString)'></script>
        <script type="text/javascript">
            window['music-rendering'].renderMusicCharacters(document.getElementsByTagName('body')[0]);

            var els = document.getElementsByTagName('img');
            for (var el of els) {
                el.setAttribute('role', 'img');
            }
        </script>
        """
    }

    private var mathJaxElements: String {
        guard contentHasMath, let mathJaxURLString = mathJaxURL?.absoluteString else {
            return ""
        }
        if intrinsicContentSize.width > 0 {
            return """
            <script type="text/x-mathjax-config" >
                MathJax.Hub.Config({displayAlign: 'inherit', showProcessingMessages: false, messageStyle: 'none', showMathMenu: false, showMathMenuMSIE: false,
                    SVG: { useFontCache: true, useGlobalCache: true, font: 'STIX-Web', linebreaks: { automatic: true, width: '\(intrinsicContentSize.width)' } } });
            </script>
            <script src='\(mathJaxURLString)'></script>
            """
        } else {
            return """
            <script type="text/x-mathjax-config" >
                MathJax.Hub.Config({displayAlign: 'inherit', showProcessingMessages: false, messageStyle: 'none', showMathMenu: false, showMathMenuMSIE: false,
                    SVG: { useFontCache: true, useGlobalCache: true, font: 'STIX-Web', linebreaks: { automatic: true } } });
            </script>
            <script src='\(mathJaxURLString)'></script>
            """
        }
    }

    private var htmlDocument: String {
        return """
        <html>
        <head>
        \(headContent)
        <meta xmlns="http://www.w3.org/1999/xhtml" content="initial-scale=1.0001, minimum-scale=1.0001, maximum-scale=1.0001, user-scalable=no" name="viewport" />
        <style xmlns="http://www.w3.org/1999/xhtml" type="text/css">
            \(hiddenCSS)

            body {
                -webkit-touch-callout: none;
                margin-top: 0px;
                margin-right: 0px;
                margin-bottom: 0px;
                margin-left: 0px;
                font-family: '-apple-system', '\(font.familyName)';
                font-size: \(font.pointSize)px;
                -webkit-text-size-adjust: 100%;
            }

            table {
                table-layout: auto;
                width: 100%;
            }

            table, td, th {
                border-collapse: collapse;
            }

            #parent {
                display: flex;
                height: 100%;
                align-items: center;
                justify-content: \(textAlignment.cssFlexString);
            }

            #content {
                color: \(textColor.cssString);
            }
        </style>
        \(mathJaxElements)
        </head>
        <body>
        <div id="parent">
        <div id="content">
        \(contentWithPlaceholderReplaced ?? "")
        </div>
        </div>
        <script type="text/javascript">
        function getContentHeight() {
            return document.getElementById("content").clientHeight;
        }
        </script>
        \(musicRenderingElements)
        </body>
        <html>
        """
    }

    //We monitor for changes in the webview's scrollView, which alerts us that the content may have
    //rendered, or grown in size.  If we just used that to set `intrinsicContentSize`, views whose size was
    //determined by `intrinsicContentSize` would never shrink, because once they've been sized that big, their
    //scrollView would never get smaller.  Instead, we ask the webview to measure the size of the `content` div
    //that we put the content into, and use that as the calculated `intrinsicContentSize`.
    //Further: to prevent a lot of bouncing around while MathJax is doing its typesetting, we use MathJax.Hub.Queue,
    //which queues this action to occur after mathjax's current processing is complete.
    private func recalculateContentSize() {
        let callback = """
        function () {
            var newContentHeight = getContentHeight();

            window.webkit.messageHandlers['\(handlerID)'].postMessage(newContentHeight);
        }
        """

        //If the content has math, we want to queue the content height calculation for after
        //the math has rendered.  Otherwise, we can execute it immediately.
        if contentHasMath {
            webview.evaluateJavaScript("""
                MathJax.Hub.Queue(\(callback));
                """
            )
        } else {
            webview.evaluateJavaScript("""
                setTimeout(\(callback), 10);
                """)
        }
    }

    private var isShowingWebview: Bool {
        get {
            return label.superview == nil
        }
        set {
            if newValue {
                webview.isHidden = false
                label.removeFromSuperview()
            } else {
                addSubview(label)
                label.constrainToSuperviewEdges()
                webview.isHidden = true
            }
        }
    }
}

extension HTMLLabel: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let body = message.body as? CGFloat {
            self.calculatedWebContentHeight = body
            if self.label.superview != nil {
                self.webview.isHidden = false
                self.label.removeFromSuperview()
            }
            self.invalidateIntrinsicContentSize()
        }
    }
}
