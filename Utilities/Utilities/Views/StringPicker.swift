//
//  StringPicker.swift
//  Utilities
//
//  Created by jbrooks on 10/31/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import UIKit

//Lightweight UITableViewController implementation for displaying a list of strings
//This is most useful in a Settings-type environment, when you want to push a TableViewController onto 
//the nav stack displaying a list of choices and have a callback executed when the user selects something
//See the link below for the reason for not using `UITableViewController` (only needed for iOS 8 support)
//http://stackoverflow.com/questions/25139494/how-to-subclass-uitableviewcontroller-in-swift
open class StringPicker: UIViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var tableView: UITableView = {
        let newView = UITableView(frame: .zero, style: self.style)
        newView.delegate = self
        newView.dataSource = self
        return newView
    }()

    let style: UITableView.Style

    var array: [String]?
    var selectedProc: (Int, String) -> Void?
    var initialSelectedIndex: Int?

    public required init(array: [String], selectedProc:@escaping (Int, String) -> Void, initialSelectedIndex: Int? = nil, style: UITableView.Style = .grouped) {
        self.array = array
        self.selectedProc = selectedProc
        self.initialSelectedIndex = initialSelectedIndex
        self.style = style

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    open override func loadView() {
        view = tableView
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let initialSelectedIndex = initialSelectedIndex {
            let indexPath = IndexPath(row: initialSelectedIndex, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array!.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "default") ?? UITableViewCell(style: .default, reuseIdentifier: "default")

        cell.textLabel?.text = array![indexPath.row]

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProc(indexPath.row, array![indexPath.row])

        //Assumes this guy is presented in a nav controller
        _ = navigationController?.popViewController(animated: true)
    }
}
