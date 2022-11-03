//
//  AlertManager.swift
//  Utilities
//
//  Created by Chien, Arnold on 4/12/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

public protocol AlertManager {}

public extension AlertManager where Self: UIViewController {
    
    /**
     Show alert with the given title, message, and actions.
     - Parameter title: the edges.
     - Parameter message: the color.
     - Parameter actions: the thickness.
     */
    func showAlert(_ title: String, message: String, actions: [UIAlertAction]) {
        let alert = createAlertController(title, message: message, actions: actions)
        present(alert, animated: true, completion: nil)
    }

    /**
     Create alert with the given title, message, and actions.
     - Parameter title: the edges.
     - Parameter message: the color.
     - Parameter actions: the thickness.
     - Returns: the alert.
     */
    func createAlertController(_ title: String, message: String, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        return alert
    }
}
