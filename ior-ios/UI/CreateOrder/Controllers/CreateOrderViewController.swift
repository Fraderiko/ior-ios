//
//  CreateOrderViewController.swift
//  ior-ios
//
//  Created by me on 25/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner

class CreateOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var order: [String: Any] = ["number" : "", "date": "", "updated" : "", "type" : "" , "currentstatus" : "", "assignedTo" : "", "comment" : "", "statuses" : "", "createdBy" : "", "group": "", "recipientmail": "", "recipientphone": "", "client": "", "cancelReason" : ""]
    
    var canWorkWith: [User] = []
    var canWorkWithGroups: [Egroup] = []
    var orderTemplates: [OrderTemplate] = []
    
    var orderCreated: (() -> ())?
    
    lazy var viewModel: CreateOrderViewModel = {
        return CreateOrderViewModel()
    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var saveButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Создать заказ", for: .normal)
        button.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.getCanWorkWith { (canWorkWith, canWorkWithGroups, orderTemplates) in
            self.canWorkWith = canWorkWith
            self.orderTemplates = orderTemplates
            self.canWorkWithGroups = canWorkWithGroups
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let type = Settings.userType() {
            if type == .Employee {
                if order["number"] as? String ?? "" != "" && order["type"] as? String ?? "" != "" && order["client"] as? String ?? "" != "" {
                    saveButton.isHidden = false
                }
            } else {
                if order["number"] as? String ?? "" != "" && order["type"] as? String ?? "" != "" && order["assignedTo"] as? String ?? "" != "" {
                    saveButton.isHidden = false
                }
            }
        }
        
        
    }
    
    func setupViews() {
        
        tableView.register(ValueCell.self, forCellReuseIdentifier: NSStringFromClass(ValueCell.self))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(cancelDidTapped))
        
        title = "Создать заказ"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
        
        view.addSubview(saveButton)
        
        saveButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.height.equalTo(60)
        })
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyz0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    @objc func cancelDidTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func save(_ sender: UIButton) {
        
        viewModel.getGroup(_id: getClientID()) { (groupID) in
            guard let index = self.orderTemplates.index(where: { $0.name == self.order["type"] as? String ?? "" }) else { return }
            let orderTemplate = NewOrder(number: (self.order["number"] as? String ?? "") + "-" + self.randomString(length:5),
                                                    date: Date().timeIntervalSince1970.rounded() * 1000,
                                                    updated: Date().timeIntervalSince1970.rounded() * 1000,
                                                    type: self.orderTemplates[index]._id,
                                                    currentstatus: "Создан",
                                                    assignedTo: self.resolveAssignedTo(),
                                                    assignedToGroup: self.resolveAssignedToGroup(),
                                                    comment: self.order["comment"] as? String ?? "",
                                                    statuses: self.orderTemplates[index].statuses,
                                                    createdBy: Settings.userId() ?? "",
                                                    group: groupID,
                                                    recipientmail: self.order["recipientmail"] as? String ?? "",
                                                    recipientphone: self.order["recipientphone"] as? String ?? "",
                                                    client: self.resolveClient(),
                                                    cancelReason: "",
                                                    discussion: [],
                                                    isArchived: false)
            self.viewModel.createOrder(order: orderTemplate, completion: { success in
                
                if success {
                    guard let orderCreated = self.orderCreated else { return }
                    orderCreated()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let banner = Banner(title: "Ошибка! Заказ с таким номером уже существует", subtitle: "", image: nil, backgroundColor: UIColor.red)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                }

            })
        }
    }
    
    func resolveAssignedTo() -> String {
        if let type = Settings.userType() {
            if type == .Employee {
                return Settings.userId() ?? ""
            } else {
                guard let index = canWorkWith.index(where: { $0.name == self.order["assignedTo"] as? String ?? ""}) else { return "" }
                return canWorkWith[index]._id
            }
        } else {
            return ""
        }
    }
    
    func resolveAssignedToGroup() -> String {
        guard let index = canWorkWithGroups.index(where: { $0.name == self.order["assignedTo"] as? String ?? ""}) else { return "" }
        return canWorkWithGroups[index]._id
    }
    
    func resolveClient() -> String {
        if let type = Settings.userType() {
            if type == .Employee {
                guard let index = canWorkWith.index(where: { $0.name == self.order["client"] as? String ?? ""}) else { return "" }
                return canWorkWith[index]._id
            } else {
                return Settings.userId() ?? ""
            }
        } else {
            return ""
        }
    }
    
    func getClientID() -> String {
        if let type = Settings.userType() {
            if type == .Employee {
                guard let index = canWorkWith.index(where: { $0.name == self.order["client"] as? String ?? ""}) else { return "" }
                return canWorkWith[index]._id
            } else {
                return Settings.userId() ?? ""
            }
        } else {
            return ""
        }
    }
}

extension CreateOrderViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ValueCell.self), for: indexPath) as? ValueCell else { return UITableViewCell() }
        if indexPath.row == 0 {
            cell.textLabel?.text = "Номер"
            cell.accessoryType = .disclosureIndicator
            if order["number"] as? String ?? "" == ""  {
                cell.detailTextLabel?.text = "Укажите номер"
            } else {
                cell.detailTextLabel?.text = order["number"] as? String ?? ""
            }
        }
        
        if indexPath.row == 1 {
            cell.textLabel?.text = "Тип"
            cell.accessoryType = .disclosureIndicator
            if order["type"] as? String ?? "" == ""  {
                cell.detailTextLabel?.text = "Укажите тип"
            } else {
                cell.detailTextLabel?.text = order["type"] as? String ?? ""
            }
        }
        
        if indexPath.row == 2 {
            cell.textLabel?.text = getUserTitle()
            cell.accessoryType = .disclosureIndicator
            
            if let type = Settings.userType() {
                if type == .Client {
                    if order["assignedTo"] as? String ?? "" == ""  {
                        cell.detailTextLabel?.text = "Укажите"
                    } else {
                        cell.detailTextLabel?.text = order["assignedTo"] as? String ?? ""
                    }
                } else {
                    if order["client"] as? String ?? "" == ""  {
                        cell.detailTextLabel?.text = "Укажите"
                    } else {
                        cell.detailTextLabel?.text = order["client"] as? String ?? ""
                    }
                }
            }
        }
        
        if indexPath.row == 3 {
            cell.textLabel?.text = "Комментарий"
            cell.accessoryType = .disclosureIndicator
            if order["comment"] as? String ?? "" == ""  {
                cell.detailTextLabel?.text = "Укажите комментарий"
            } else {
                cell.detailTextLabel?.text = order["comment"] as? String ?? ""
            }
        }
        
        if indexPath.row == 4 {
            cell.textLabel?.text = "Email"
            cell.accessoryType = .disclosureIndicator
            if order["recipientmail"] as? String ?? "" == ""  {
                cell.detailTextLabel?.text = "Укажите почту получателя"
            } else {
                cell.detailTextLabel?.text = order["recipientmail"] as? String ?? ""
            }
        }
        
        if indexPath.row == 5 {
            cell.textLabel?.text = "Телефон"
            cell.accessoryType = .disclosureIndicator
            if order["recipientphone"] as? String ?? "" == ""  {
                cell.detailTextLabel?.text = "Укажите телефон получателя"
            } else {
                cell.detailTextLabel?.text = order["recipientphone"] as? String ?? ""
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let controller = TextFieldViewController(_id: "", value: order["number"] as? String ?? "", mode: .Text, title: "Номер", completion: { (_, text) in
                self.order["number"] = text
                self.tableView.reloadData()
            })
            controller.isNumber = true
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if indexPath.row == 1 {
            let controller = TableViewController()
            controller.value = orderTemplates.map({ return $0.name })
            controller.completion = { (type) in
                self.order["type"] = type
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if indexPath.row == 2 {
            let controller = TableViewController()
            
            var users = canWorkWith.map({ return $0.name })
            var groups = canWorkWithGroups.map({ return $0.name })
            
            controller.value = users + groups
            controller.completion = { (selectedUser) in
                if let type = Settings.userType() {
                    if type == .Client {
                        self.order["assignedTo"] = selectedUser
                    } else {
                        self.order["client"] = selectedUser
                    }
                }
                self.tableView.reloadData()
            }
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if indexPath.row == 3 {
            let controller = TextViewViewController(value: order["comment"] as? String ?? "", mode: .Field, title: "Комментарий", completion: { (text) in
                self.order["comment"] = text
                self.tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if indexPath.row == 4 {
            let controller = TextFieldViewController(_id: "", value: order["recipientmail"] as? String ?? "", mode: .Text, title: "Емейл получателя", completion: { (_, text) in
                self.order["recipientmail"] = text
                self.tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if indexPath.row == 5 {
            let controller = TextFieldViewController(_id: "", value: order["recipientphone"] as? String ?? "", mode: .Digits, title: "Телефон получателя", completion: { (_, text) in
                self.order["recipientphone"] = text
                self.tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func getUserTitle() -> String {
        if let type = Settings.userType() {
            if type == .Employee {
                return "Клиент"
            } else {
                return "Исполнитель"
            }
        }
        return ""
    }
}

class ValueCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
