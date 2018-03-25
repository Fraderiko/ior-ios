//
//  ProfileViewController.swift
//  ior-ios
//
//  Created by me on 25/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            self.nameTextField.text = user.name
            self.phoneTextField.text = user.phone
            self.mailTextField.text = user.mail
            
            if let type = Settings.userType() {
                if type == .Client {
                    newStatusesSwitch.isOn = user.new_status_notification
                    newStatusesPushSwitch.isOn = user.new_status_notification
                } else {
                    newOrdersSwitch.isOn = user.new_orders_notification
                    newOrdersPushSwitch.isOn = user.new_orders_notification
                }
            }
            
            newChatSwitch.isOn = user.new_chat_notification
        }
    }
    
    lazy var viewModel: ProfileViewModel = {
        return ProfileViewModel()
    }()
    
    lazy var nameTextField: UITextField = {
        var view = UITextField()
        view.borderStyle = UITextBorderStyle.roundedRect
        view.placeholder = "Имя"
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        view.autocorrectionType = .no
        view.keyboardType = .emailAddress
        view.inputAssistantItem.leadingBarButtonGroups = []
        view.inputAssistantItem.trailingBarButtonGroups = []
        view.delegate = self
        return view
    }()
    
    lazy var mailTextField: UITextField = {
        var view = UITextField()
        view.borderStyle = UITextBorderStyle.roundedRect
        view.placeholder = "Почта"
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        view.autocorrectionType = .no
        view.keyboardType = .emailAddress
        view.inputAssistantItem.leadingBarButtonGroups = []
        view.inputAssistantItem.trailingBarButtonGroups = []
        view.delegate = self
        return view
    }()
    
    lazy var phoneTextField: UITextField = {
        var view = UITextField()
        view.borderStyle = UITextBorderStyle.roundedRect
        view.placeholder = "Телефон"
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        view.autocorrectionType = .no
        view.keyboardType = .emailAddress
        view.inputAssistantItem.leadingBarButtonGroups = []
        view.inputAssistantItem.trailingBarButtonGroups = []
        view.delegate = self
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "ФИО"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var phoneLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Телефон"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var mailLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Почта"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var saveButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    lazy var newOrdersLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Присылать почтовые уведомления о новых заказах"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var newStatusesLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Присылать почтовые уведомления о новых статусах"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var newOrdersSwitch: UISwitch = {
        var view = UISwitch()
        view.addTarget(self, action: #selector(newOrdersSwitchHandler(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var newStatusesSwitch: UISwitch = {
        var view = UISwitch()
        view.addTarget(self, action: #selector(newStatusesSwitchHandler(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var newChatSwitch: UISwitch = {
        var view = UISwitch()
        view.addTarget(self, action: #selector(newChatSwitchHandler(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var newChatLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Присылать почтовые уведомления о новых сообщениях в чате"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var newOrdersPushLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Присылать push уведомления о новых заказах"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var newStatusesPushLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        label.text = "Присылать push уведомления о новых статусах"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var newOrdersPushSwitch: UISwitch = {
        var view = UISwitch()
        view.addTarget(self, action: #selector(newOrdersPushSwitchHandler(_:)), for: .valueChanged)
        return view
    }()
    
    lazy var newStatusesPushSwitch: UISwitch = {
        var view = UISwitch()
        view.addTarget(self, action: #selector(newStatusesPushSwitchHandler(_:)), for: .valueChanged)
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.getProfile { (user) in
            self.user = user
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Выход", style: .plain, target: self, action: #selector(logout))
    }
    
    @objc func newOrdersSwitchHandler(_ sender: UISwitch) {
        guard let user = user else { return }
        let result = sender.isOn
        user.new_orders_notification = result
        saveButton.isHidden = false
    }
    
    @objc func newChatSwitchHandler(_ sender: UISwitch) {
        guard let user = user else { return }
        let result = sender.isOn
        user.new_chat_notification = result
        saveButton.isHidden = false
    }
    
    @objc func newStatusesSwitchHandler(_ sender: UISwitch) {
        guard let user = user else { return }
        let result = sender.isOn
        user.new_status_notification = result
        saveButton.isHidden = false
    }
    
    @objc func newOrdersPushSwitchHandler(_ sender: UISwitch) {
        guard let user = user else { return }
        let result = sender.isOn
        user.new_orders_push_notification = result
        saveButton.isHidden = false
    }
    
    @objc func newStatusesPushSwitchHandler(_ sender: UISwitch) {
        guard let user = user else { return }
        let result = sender.isOn
        user.new_status_push_notification = result
        saveButton.isHidden = false
    }
    
    @objc func logout() {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
        let controller = LoginViewController()
        UIApplication.shared.unregisterForRemoteNotifications()
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func save(_ sender: UIButton) {
        guard let user = user, let name = self.nameTextField.text, let phone = self.phoneTextField.text, let mail = self.mailTextField.text else { return }
        
        if name.isEmpty || phone.isEmpty || mail.isEmpty {
            let banner = Banner(title: "Все поля обязательны для заполнения", subtitle: "", image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            return
        }
        
        user.phone = phone
        user.name = name
        user.mail = mail
        
        viewModel.updateProfile(user: user) {
            let banner = Banner(title: "Профиль успешно обновлен", subtitle: "", image: nil, backgroundColor: UIColor.blue)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            self.saveButton.isHidden = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        guard let user = user else { return true }
        
        if self.nameTextField.text != user.name || self.phoneTextField.text != user.phone || self.mailTextField.text != user.mail {
            saveButton.isHidden = false
        }
        
        return true
    }
    
    func setupViews() {
        
        view.backgroundColor = .white
        
        title = "Профиль"
        
        view.addSubview(nameTextField)
        view.addSubview(mailTextField)
        view.addSubview(phoneTextField)
        view.addSubview(saveButton)
        view.addSubview(nameLabel)
        view.addSubview(phoneLabel)
        view.addSubview(mailLabel)
        view.addSubview(newChatSwitch)
        view.addSubview(newChatLabel)
        if let type = Settings.userType() {
            if type == .Client {
                view.addSubview(newStatusesLabel)
                view.addSubview(newStatusesSwitch)
                view.addSubview(newStatusesPushLabel)
                view.addSubview(newStatusesPushSwitch)
                
                newChatLabel.snp.makeConstraints({ make in
                    make.top.equalTo(self.phoneTextField.snp.bottom).offset(40)
                    make.left.equalTo(self.view.snp.left).offset(40)
                    make.right.equalTo(self.view.snp.right).offset(-100)
                })
                
                newChatSwitch.snp.makeConstraints({ make in
                    make.centerY.equalTo(self.newChatLabel.snp.centerY)
                    make.right.equalTo(self.view.snp.right).offset(-40)
                })
                
                newStatusesLabel.snp.makeConstraints({ make in
                    make.top.equalTo(self.newChatLabel.snp.bottom).offset(40)
                    make.left.equalTo(self.view.snp.left).offset(40)
                    make.right.equalTo(self.view.snp.right).offset(-100)
                })
                
                newStatusesSwitch.snp.makeConstraints({ make in
                    make.centerY.equalTo(self.newStatusesLabel.snp.centerY)
                    make.right.equalTo(self.view.snp.right).offset(-40)
                })
                
                newStatusesPushLabel.snp.makeConstraints({ make in
                    make.top.equalTo(self.newStatusesLabel.snp.bottom).offset(40)
                    make.left.equalTo(self.view.snp.left).offset(40)
                    make.right.equalTo(self.view.snp.right).offset(-100)
                })
                
                newStatusesPushSwitch.snp.makeConstraints({ make in
                    make.centerY.equalTo(self.newStatusesPushLabel.snp.centerY)
                    make.right.equalTo(self.view.snp.right).offset(-40)
                })
                
            } else {
                view.addSubview(newOrdersLabel)
                view.addSubview(newOrdersSwitch)
                view.addSubview(newOrdersPushLabel)
                view.addSubview(newOrdersPushSwitch)
                
                newChatLabel.snp.makeConstraints({ make in
                    make.top.equalTo(self.phoneTextField.snp.bottom).offset(40)
                    make.left.equalTo(self.view.snp.left).offset(40)
                    make.right.equalTo(self.view.snp.right).offset(-100)
                })
                
                newChatSwitch.snp.makeConstraints({ make in
                    make.centerY.equalTo(self.newChatLabel.snp.centerY)
                    make.right.equalTo(self.view.snp.right).offset(-40)
                })
                
                newOrdersLabel.snp.makeConstraints({ make in
                    make.top.equalTo(self.newChatLabel.snp.bottom).offset(40)
                    make.left.equalTo(self.view.snp.left).offset(40)
                    make.right.equalTo(self.view.snp.right).offset(-100)
                })
                
                newOrdersSwitch.snp.makeConstraints({ make in
                    make.centerY.equalTo(self.newOrdersLabel.snp.centerY)
                    make.right.equalTo(self.view.snp.right).offset(-40)
                })
                
                newOrdersPushLabel.snp.makeConstraints({ make in
                    make.top.equalTo(self.newOrdersLabel.snp.bottom).offset(40)
                    make.left.equalTo(self.view.snp.left).offset(40)
                    make.right.equalTo(self.view.snp.right).offset(-100)
                })
                
                newOrdersPushSwitch.snp.makeConstraints({ make in
                    make.centerY.equalTo(self.newOrdersPushLabel.snp.centerY)
                    make.right.equalTo(self.view.snp.right).offset(-40)
                })
            }
        }
        
        nameLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.nameTextField.snp.left)
            make.bottom.equalTo(self.nameTextField.snp.top).offset(-10)
        })
        
        nameTextField.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(100)
            make.left.equalTo(self.view.snp.left).offset(40)
            make.right.equalTo(self.view.snp.right).offset(-40)
        })
        
        mailLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.mailTextField.snp.left)
            make.bottom.equalTo(self.mailTextField.snp.top).offset(-10)
        })
        
        mailTextField.snp.makeConstraints({ make in
            make.top.equalTo(self.nameTextField.snp.bottom).offset(40)
            make.left.equalTo(self.view.snp.left).offset(40)
            make.right.equalTo(self.view.snp.right).offset(-40)
        })
        
        phoneLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.phoneTextField.snp.left)
            make.bottom.equalTo(self.phoneTextField.snp.top).offset(-10)
        })
        
        phoneTextField.snp.makeConstraints({ make in
            make.top.equalTo(self.mailTextField.snp.bottom).offset(40)
            make.left.equalTo(self.view.snp.left).offset(40)
            make.right.equalTo(self.view.snp.right).offset(-40)
        })
        
        saveButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.height.equalTo(60)
        })
    }
}
