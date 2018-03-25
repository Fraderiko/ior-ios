//
//  OrderViewController.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, OrderCellDelegate {
    
    var order: Order?
    var completion: (() -> ())?
    var keyboardDidShow: Bool = false
    var userCanEditOrder: Bool = false
    var userCanCancel: Bool = false
    
    var discussionCompletion: (() -> ())?
    
    lazy var viewModel: OrderViewModel = {
        var viewModel = OrderViewModel()
        return viewModel
    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderDetailsCell.self, forCellReuseIdentifier: NSStringFromClass(OrderDetailsCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.register(TextCell.self, forCellReuseIdentifier: NSStringFromClass(TextCell.self))
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    lazy var cancelButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Отменить заказ", for: .normal)
        button.addTarget(self, action: #selector(cancelOrder(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    lazy var cancelReasonTextField: UITextField = {
        var textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 22)
        textField.isHidden = true
        textField.placeholder = "Укажите причину отмены"
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = order?.number
        setupKeyboardNotifications()
        viewModel.getUserPermissions { (userCanEditOrder, userCanCancel) in
            self.userCanEditOrder = userCanEditOrder
            self.userCanCancel = userCanCancel
            
            if (userCanCancel) {
                self.cancelButton.isHidden = false
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Чат", style: .done, target: self, action: #selector(showChat))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func showChat() {
        guard let order = order else { return }
        let chatController = ChatViewController()
        chatController.orderID = order._id
        chatController.orderNumber = order.number
        
        var users: [String] = []
        
        for message in order.messages {
            if (users.contains(message.username) == false) {
                users.append(message.username)
            }
        }
        
        var names: [String: String] = [:]
        
        var counter = 0
        
        
        if users.count > 0 {
            for user in users {
                APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(user)", completion: { (response, error) in
                    guard let response = response as? [String: Any] else { return }
                    var name = response["name"] as? String ?? ""
                    names[user] = name
                    counter = counter + 1
                    if counter == users.count {
                        chatController.names = names
                        self.navigationController?.pushViewController(chatController, animated: true)
                    }
                })
            }
        } else {
            chatController.names = names
            self.navigationController?.pushViewController(chatController, animated: true)
        }
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if keyboardDidShow == false {
            keyboardDidShow = true
            if let userInfo = sender.userInfo {
                let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
                updateConstraintsWithKeyboard(height: keyboardHeight)
                animateLayout()
            }
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        updateConstraintsWithKeyboard(height: 0)
        animateLayout()
        keyboardDidShow = false
    }
    
    func animateLayout() {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateConstraintsWithKeyboard(height: CGFloat) {
        guard let order = order else { return }
        if order.statuses.filter({ $0.state == "Filled" }).isEmpty && Settings.userType() == .Client {
            cancelReasonTextField.snp.updateConstraints({ (make) in
                make.bottom.equalTo(self.cancelButton.snp.top).offset(-height / 2)
            })
        }
    }
    
    @objc func cancelOrder(_ sender: UIButton) {
        guard let order = order else { return }
        if cancelReasonTextField.isHidden == true {
            cancelReasonTextField.isHidden = false
            cancelReasonTextField.becomeFirstResponder()
            return
        }
        
        if cancelReasonTextField.text == "" {
            let banner = Banner(title: "Ошибка! Укажите причину отмены", subtitle: "", image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            return
        } else {
            var order = order
            order.currentstatus = "Отменен"
            order.cancelReason = cancelReasonTextField.text ?? ""
            viewModel.cancel(order: order, completion: {
                guard let completion = self.completion else { return }
                self.navigationController?.popViewController(animated: true)
                completion()
            })
        }
    }
    
    func favDidTapped(isFav: Bool, index: Int) {
        guard let order = order else { return }
        if isFav {
            viewModel.addToFav(_id: Settings.userId() ?? "", order_id: order._id, completion: {
                //
            })
        } else {
            viewModel.removeFromFav(_id: Settings.userId() ?? "", order_id: order._id, completion: {
                //
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let order = order else { return 0 }
        let sectionForInfo = 1
        var sectionForDiscussion = 0
        if order.discussion.isEmpty == false && Settings.userType() == .Client ?? .Client {
            sectionForDiscussion = 1
        }
        let sectionForStatuses = 1
        return sectionForInfo + sectionForStatuses + sectionForDiscussion
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let order = order else { return 0 }
        
        if section == 0 {
            return 1
        }
        
        if section == 1 {
            if Settings.userType() == .Client {
                return viewModel.numberOfStatusesToShow(order: order)
            } else {
                return order.statuses.count
            }
        }
        
        if section == 2 {
            return 1
        }
        
        
        return 0
        
    }
    
    func setupViews() {
        guard let order = order else { return }
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
        
        if order.statuses.filter({ $0.state == "Filled" }).isEmpty && Settings.userType() == .Client && order.currentstatus == "Создан" {
            view.addSubview(cancelButton)
            cancelButton.snp.makeConstraints({ make in
                make.left.equalTo(self.view.snp.left)
                make.right.equalTo(self.view.snp.right)
                make.bottom.equalTo(self.view.snp.bottom).offset(-50)
                make.height.equalTo(60)
            })
            view.addSubview(cancelReasonTextField)
            cancelReasonTextField.snp.makeConstraints({ make in
                make.left.equalTo(self.view.snp.left).offset(50)
                make.right.equalTo(self.view.snp.right).offset(-50)
                make.bottom.equalTo(self.cancelButton.snp.top)
                make.height.equalTo(120)
            })
        }
    }
    
    func shouldHideStatus(index: Int) -> Bool {
        guard let order = order else { return false }
        let filtered = order.statuses.filter({ $0.state == "" })
        if filtered.first?._id != order.statuses[index]._id {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let order = order else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OrderDetailsCell.self), for: indexPath) as? OrderDetailsCell else { return UITableViewCell() }
            cell.order = order
            cell.delegate = self
            return cell
        }
        
        if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as? UITableViewCell else { return UITableViewCell() }
            cell.textLabel?.text = order.statuses[indexPath.row].name
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        if indexPath.section == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
            cell.textLabel?.text = "Обратная связь"
            cell.detailTextLabel?.text = String(order.discussion.count)
            return cell
        }
        
        return  UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let order = order else { return }
        
        if indexPath.section == 1 {
            let status = order.statuses[indexPath.row]
            
            if status.state == "Filled" {
                let controller = FilledStatusViewController()
                controller.index = indexPath.row
                controller.status = status
                controller.userCanEditOrder = userCanEditOrder
                controller.editBlock = { (status, index) in
                    var orderCopy = order
                    orderCopy.statuses[index] = status
                    self.viewModel.editOrder(order: orderCopy) {
                        self.navigationController?.popViewController(animated: true)
                        let banner = Banner(title: "Заказ успешно отредактирован", subtitle: "", image: nil, backgroundColor: UIColor.blue)
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                    }
                }
                navigationController?.pushViewController(controller, animated: true)
            } else if status.state == "" {
                let controller = FillNewStatusViewController()
                controller.order = order
                controller.status = status
                controller.isStatusHidden = shouldHideStatus(index: indexPath.row)
                controller.completion = {
                    guard let completion = self.completion else { return }
                    completion()
                }
                navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        if indexPath.section == 2 {
            let controller = DiscussionViewController()
            controller.discussions = order.discussion
            controller.order = order
            if let discussionCompletion = discussionCompletion {
                controller.completion = {
                    discussionCompletion()
                }
            }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

class OrderDetailsCell: OrderCell {
    
    override var order: Order? {
        didSet {
            guard let order = order else { return }
            self.number.text = order.number
            self.date.text = Date(timeIntervalSince1970: order.date / 1000).formattedDate()
            self.updated.text = Date(timeIntervalSince1970: order.updated / 1000).formattedDate()
            self.type.text = String(order.type.name)
            
            if let name = order.assignedTo {
                self.user.text = name.name
            } else {
                self.user.text = order.assignedToGroup?.name ?? ""
            }
            
            self.comment.text = order.comment
        }
    }
    
    lazy var commentLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Комментарий"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var comment: UILabel = {
        var label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        addSubview(commentLabel)
        addSubview(comment)
        
        userLabel.snp.remakeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.type.snp.bottom).offset(10)
        })
        
        user.snp.remakeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.type.snp.bottom).offset(10)
        })
        
        commentLabel.snp.remakeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(20)
            make.top.equalTo(self.user.snp.bottom).offset(10)
            make.bottom.equalTo(self.snp.bottom).offset(-20)

        })
        
        comment.snp.remakeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-40)
            make.top.equalTo(self.user.snp.bottom).offset(10)
            make.width.equalTo(140)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        })
    }
}
