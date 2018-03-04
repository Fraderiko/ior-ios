//
//  TableViewController.swift
//  ior-ios
//
//  Created by me on 25/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: CreateOrderViewController {
 
    var completion: ((String) -> ())?
    
    var value: [String] = []
    var selectedIndex: Int? {
        didSet {
            saveButton.isHidden = false
        }
    }
    
    override func setupViews() {
        super.setupViews()
        saveButton.snp.updateConstraints({ make in
            make.bottom.equalTo(self.view.snp.bottom)
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        saveButton.setTitle("Выбрать", for: .normal)
        navigationItem.leftBarButtonItem = nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as? UITableViewCell else { return UITableViewCell() }
        cell.textLabel?.text = value[indexPath.row]
        if let selectedIndex = selectedIndex {
            if indexPath.row == selectedIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return value.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    override func save(_ sender: UIButton) {
        if let completion = completion, let selectedIndex = selectedIndex {
            completion(value[selectedIndex])
            navigationController?.popViewController(animated: true)
        }
    }
    
}
