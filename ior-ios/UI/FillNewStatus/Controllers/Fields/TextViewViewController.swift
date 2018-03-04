//
//  TextFieldViewController.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner

class TextViewViewController: UIViewController, UITextViewDelegate {
    
    convenience init(value: String, mode: TextViewMode, title: String, completion: ((String) -> ())? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.mode = mode
        self.title = title
        self.value = value
        self.completion = completion
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum TextViewMode {
        case Field
        case Feedback
        case None
    }
    
    var mode: TextViewMode = .None
    var value: String?
    var completion: ((String) -> ())?
    
    lazy var textView: UITextView = {
        var textField = UITextView()
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.text = value
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        textView.becomeFirstResponder()
        
        if self.mode == .Field {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action:  #selector(save(_:)))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить", style: .plain, target: self, action:  #selector(send(_:)))
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @objc func save(_ sender: UIButton) {
        guard let completion = completion, let text = textView.text else { return }
        completion(text)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func send(_ sender: UIButton) {
        
        guard let text = textView.text as? String else { return }
        
        if text.isEmpty {
            let banner = Banner(title: "Сообщение не может быть пустым", subtitle: "", image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            return
        }
        
        APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(Settings.userId() ?? "")") { (response, error) in
            guard let response = response as? [String: Any] else { return }
            let mail = response["mail"] as? String ?? ""
            APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/feedback", parameters: ["message": self.textView.text ?? "", "sender": mail]) { (response, error) in
                let banner = Banner(title: "Сообщение отправлено", subtitle: "", image: nil, backgroundColor: UIColor.blue)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.view.endEditing(true)
                self.textView.text = ""
            }
        }
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(textView)
        textView.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(100)
            make.left.equalTo(self.view.snp.left).offset(20)
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.height.equalTo(300)
        })
    }
    
}

