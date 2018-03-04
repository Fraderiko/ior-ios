//
//  LoginViewController.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import BRYXBanner

class LoginViewController: UIViewController {
    
    lazy var viewModel: LoginViewModel = {
        var viewModel = LoginViewModel()
        return viewModel
    }()
    
    lazy var container: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var loginTextField: UITextField = {
        var view = UITextField()
        view.borderStyle = UITextBorderStyle.roundedRect
        view.placeholder = "Введите логин"
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        view.autocorrectionType = .no
        view.keyboardType = .emailAddress
        view.inputAssistantItem.leadingBarButtonGroups = []
        view.inputAssistantItem.trailingBarButtonGroups = []
        return view
    }()
    
    lazy var passwordTextField: UITextField = {
        var view = UITextField()
        view.borderStyle = UITextBorderStyle.roundedRect
        view.placeholder = "Введите пароль"
        view.isSecureTextEntry = true
        return view
    }()
    
    lazy var loginButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc
    func loginButtonTapped(_ sender: UIButton) {
    
        guard let login = loginTextField.text else { return }
        
        guard let password = passwordTextField.text else { return }
        
        if login.isEmpty || password.isEmpty {
            
            let banner = Banner(title: "Заполните логин и пароль", subtitle: "", image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            
            return
        }
        
        viewModel.performAuth(login: loginTextField.text ?? "", password: passwordTextField.text ?? "") { (success) in
            if success {
                if let type = Settings.userType() {
                    if type == .OrderDetails {
                        let controller = UINavigationController(rootViewController: OrderForRecepientViewController())
                        self.present(controller, animated: true, completion: nil)
                    } else {
                        let tabBarContoller = UITabBarController()
                        let profile = UINavigationController(rootViewController: ProfileViewController())
                        let orders = UINavigationController(rootViewController: OrderListViewController())
                        let favorites = UINavigationController(rootViewController: OrderListViewController(favMode: true))
                        let feedback = UINavigationController(rootViewController: TextViewViewController(value: "", mode: .Feedback, title: "Поддержка"))
                        
                        let controllers = [orders, favorites, profile, feedback]
                        tabBarContoller.viewControllers = controllers
                        
                        profile.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(named: "profile"), tag: 0)
                        orders.tabBarItem = UITabBarItem(title: "Заказы", image: UIImage(named: "orders"), tag: 1)
                        favorites.tabBarItem = UITabBarItem(title: "Избранные", image: UIImage(named: "star-tab"), tag: 2)
                        feedback.tabBarItem = UITabBarItem(title: "Поддержка", image: UIImage(named: "support"), tag: 3)
                        
                        self.present(tabBarContoller, animated: true, completion: nil)
                    }
                }
            } else {
                let banner = Banner(title: "Неправильные логин пароль", subtitle: "", image: nil, backgroundColor: UIColor.red)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }
        }
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(container)
        container.addSubview(loginTextField)
        container.addSubview(passwordTextField)
        container.addSubview(loginButton)
        
        container.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            make.width.equalTo(UIScreen.main.bounds.width - UIScreen.main.bounds.width / 4)
            make.height.equalTo(160)
        })
        
        loginTextField.snp.makeConstraints({ make in
            make.centerX.equalTo(self.container.snp.centerX)
            make.top.equalTo(self.container.snp.top).offset(30)
            make.left.equalTo(self.container.snp.left).offset(40)
            make.right.equalTo(self.container.snp.right).offset(-40)
        })
        
        passwordTextField.snp.makeConstraints({ make in
            make.centerX.equalTo(self.container.snp.centerX)
            make.top.equalTo(self.loginTextField.snp.bottom).offset(20)
            make.left.equalTo(self.container.snp.left).offset(40)
            make.right.equalTo(self.container.snp.right).offset(-40)
        })
        
        loginButton.snp.makeConstraints({ make in
            make.centerX.equalTo(self.container.snp.centerX)
            make.top.equalTo(self.passwordTextField.snp.bottom).offset(10)
        })
    }
}
