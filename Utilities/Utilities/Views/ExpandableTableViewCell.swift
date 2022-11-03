//
//  ExpandableTableViewCell.swift
//  Utilities
//
//  Created by Brooks, Jon on 5/20/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//

import UIKit

public protocol ExpandableCellDelegate: AnyObject {
    func didToggle(_ sender: ExpandableTableViewCell)
}

/**
    ExpandableTableViewCell is a UITableViewCell subclass that has text truncated to 2 lines, and a Show More button for expanding
    the text.  It is a requirement of the client to wire up `toggleButton` and `expandingLabelText` to ui elements in the xib.
    It is up to the client how they are laid out, as long as the height of the cell is determined by the heights of its subviews with constraints.
    (This allows for automatic cell sizing to work properly.)
 */
open class ExpandableTableViewCell: UITableViewCell {
    @IBOutlet open weak var toggleButton: UIButton!
    @IBOutlet open weak var expandingLabelText: UILabel!

    @IBInspectable open var lessText: String = NSLocalizedString(
        "Show less",
        bundle: Bundle.module,
        comment: "Title of button that hides the full text on an annotation item in the list"
    )

    @IBInspectable open var moreText: String = NSLocalizedString(
        "Show more",
        bundle: Bundle.module,
        comment: "Title of button that shows the full text on an annotation item in the list"
    )

    public weak var delegate: ExpandableCellDelegate?

    open var expanded: Bool = false {
        didSet {
            setToggleTitle()
            adjustCell()
        }
    }

    open func adjustCell() {
        expandingLabelText.numberOfLines = expanded ? 0 : 2
        layoutIfNeeded()
        let shouldAllowToggle = expanded || expandingLabelText.isTruncated
        toggleButton.isHidden = !shouldAllowToggle
    }

    @IBAction open func doToggle(_ sender: AnyObject) {
        expanded = !expanded

        // Let the delegate know toggle happened
        delegate?.didToggle(self)
    }

    open func setToggleTitle() {
        toggleButton.setTitle((expanded ? lessText : moreText), for: .normal)
    }
}
