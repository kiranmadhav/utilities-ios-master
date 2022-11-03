//
//  CustomAlert.swift
//  Utilities
//
//  Created by Chien, Arnold on 10/12/18.
//  Copyright © 2018 McGraw-Hill Education. All rights reserved.
//
//  Initially based roughly on https://medium.com/if-let-swift-programming/design-and-code-your-own-uialertview-ec3d8c000f0a
//

import UIKit

public protocol CustomAlertViewDelegate: AnyObject {
    func okTapped()
    func cancelTapped()
    func customTapped()
}

public extension CustomAlertViewDelegate {
    func okTapped() {}
    func cancelTapped() {}
    func customTapped() {}
}

public struct CustomAlertViewColors {
    static let gray = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
    static let black = UIColor.black.withAlphaComponent(0.4)
}

public class CustomAlertLabel: UILabel {
    override public var intrinsicContentSize: CGSize {
        if isHidden {
            return CGSize.zero
        } else {
            return super.intrinsicContentSize
        }
    }
}

// A custom configurable alert view.  Use for flexible styling of title and content, and/or a custom button.
// Callbacks are available for any button via the custom alert delegate.
public class CustomAlertViewController: UIViewController {
    // The label outlets may be used for content and styling of the title and message.
    // Either may be omitted by setting isHidden, and layout will take into account.
    @IBOutlet public weak var titleLabel: CustomAlertLabel!
    @IBOutlet public weak var messageLabel: CustomAlertLabel!
    
    /**
     Add a separator between the title and message.
     */
    public func addMessageSeparator() {
        labelSeparatorView.isHidden = false
        labelSeparatorConstraint.constant = 8
    }

    /**
     Set attributed string for title, with optional layout attribute.  For convenience; attributed string may also be set through the label outlets.
     - Parameter attributedString: view to constrain to
     - Parameter xLayoutAttribute: optional layout attribute
     */
    public func setTitleAttributedText(_ attributedString: NSAttributedString, xLayoutAttribute: NSLayoutConstraint.Attribute?) {
        titleLabel.attributedText = attributedString
        if let xAttribute = xLayoutAttribute {
            NSLayoutConstraint.deactivate([titleCenterXConstraint])
            let constraint = NSLayoutConstraint(item: titleLabel!,
                                                attribute: xAttribute,
                                                relatedBy: .equal,
                                                toItem: titleLabel.superview,
                                                attribute: .left,
                                                multiplier: 1.0,
                                                constant: 15)
            NSLayoutConstraint.activate([constraint])
        }
    }

    /**
     Set attributed string for message, with optional layout attribute.
     - Parameter attributedString: view to constrain to
     - Parameter xLayoutAttribute: optional layout attribute
     */
    public func setMessageAttributedText(_ attributedString: NSAttributedString, xLayoutAttribute: NSLayoutConstraint.Attribute?) {
        messageLabel.attributedText = attributedString
        if let xAttribute = xLayoutAttribute {
            NSLayoutConstraint.deactivate([messageCenterXConstraint])
            let constraint = NSLayoutConstraint(item: messageLabel!,
                                                attribute: xAttribute,
                                                relatedBy: .equal,
                                                toItem: titleLabel,
                                                attribute: .left,
                                                multiplier: 1.0,
                                                constant: 0)
            NSLayoutConstraint.activate([constraint])
        }
    }

    /**
     Set custom dismiss button, to appear instead of standard OK and Cancel.
     - Parameter withBackgroundColor: button background color
     - Parameter text: title text of button
     - Parameter textColor: color of text
     */
    public func setCustomButton(withBackgroundColor color: UIColor, text: String, textColor: UIColor) {
        okButton.isHidden = true
        cancelButton.isHidden = true
        horizontalSeparator.isHidden = true
        verticalSeparator.isHidden = true
        customButton.isHidden = false
        customButton.backgroundColor = color
        customButton.setTitle(text, for: .normal)
        customButton.setTitleColor(textColor, for: .normal)
    }
    
    @IBOutlet weak var labelSeparatorView: UIView!
    @IBOutlet weak var labelSeparatorConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var horizontalSeparator: UIView!
    @IBOutlet weak var verticalSeparator: UIView!
    @IBOutlet weak var customButton: UIButton!

    @IBAction func onOkTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.okTapped()
    }

    @IBAction func onCancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.cancelTapped()
    }

    @IBAction func onCustomTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.customTapped()
    }
    
    weak public var delegate: CustomAlertViewDelegate?
    
    public init() {
        super.init(nibName: nil, bundle: Bundle.module)
        self.loadViewIfNeeded()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        okButton.isHidden = false
        cancelButton.isHidden = false
        customButton.isHidden = true
        super.viewDidLoad()
        customButton.roundCornersToCreateSideBubbles(0, borderColor: .clear)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        animateView()
    }
    
    func setupView() {
        alertView.layer.cornerRadius = 15
        self.view.backgroundColor = CustomAlertViewColors.black
    }
    
    func animateView() {
        alertView.alpha = 0
        alertView.frame.origin.y += 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0
            self.alertView.frame.origin.y -= 50
        })
    }

}
