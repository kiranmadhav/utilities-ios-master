//
//  SegueHandler.swift
//  Utilities
//
//  Created by Chien, Arnold on 5/24/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public protocol SegueHandler {
    associatedtype SegueId: RawRepresentable
}

public extension SegueHandler where Self: UIViewController, SegueId.RawValue == String {
    
    /**
     Perform segue with the given id.
     - Parameter segueIdentifier: the segue id.
     - Parameter sender: the object used to initiate the segue.
     */
    func performSegueWithIdentifier(_ segueIdentifier: SegueId, sender: AnyObject?) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }

    /**
     The id of the given storyboard segue.
     - Parameter segue: the segue.
     - Returns: the segue id.
     */
    func segueIdForSegue(_ segue: UIStoryboardSegue) -> SegueId {
        guard let id = segue.identifier else {
            fatalError("Invalid segue identifier")
        }
        guard let segueId = SegueId(rawValue: id) else {
            fatalError("Could not create enum value for segue id: \(id)")
        }
        return segueId
    }
}
