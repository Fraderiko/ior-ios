//
//  TextFieldViewController.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

class TextFieldViewController: UIViewController, UITextFieldDelegate {
    
    convenience init(_id: String, value: String, mode: TextFieldMode, title: String, completion: @escaping (String, String) -> ()) {
        self.init(nibName: nil, bundle: nil)
        self.mode = mode
        self.title = title
        self._id = _id
        self.value = value
        self.completion = completion
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum TextFieldMode {
        case Text
        case Digits
        case None
    }
    
    var isNumber = false
    
    var mode: TextFieldMode = .None
    var placeholder: String = ""
    var _id: String?
    var value: String?
    var completion: ((String, String) -> ())?
    
    lazy var textField: UITextField = {
        var textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 22)
        if self.mode == .Text {
            textField.keyboardType = .default
        } else if self.mode == .Digits {
            textField.keyboardType = .decimalPad
        }
        textField.text = value
        textField.delegate = self
        textField.borderStyle = UITextBorderStyle.roundedRect
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        textField.becomeFirstResponder()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action:  #selector(save(_:)))
    }
    
    @objc func save(_ sender: UIButton) {
        guard let completion = completion, let text = textField.text, let _id = _id else { return }
        completion(_id, text)
        navigationController?.popViewController(animated: true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if isNumber == true {
            let condition = "[^a-zA-Z0-9]"
            return !NSPredicate(format: "SELF MATCHES %@", condition).evaluate(with: string)
        } else {
            return true
        }
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(textField)
        textField.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(200)
            make.left.equalTo(self.view.snp.left).offset(80)
            make.right.equalTo(self.view.snp.right).offset(-80)
        })
    }
    
}
