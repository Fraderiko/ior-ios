//
//  DatePickerViewController.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

class DatePickerViewController: UIViewController {
    
    convenience init(_id: String, value: String, mode: DatePickerMode, title: String, completion: @escaping (String, String) -> ()) {
        self.init(nibName: nil, bundle: nil)
        self.mode = mode
        self.title = title
        self._id = _id
        
        self.completion = completion
        
        let dateFormatter = DateFormatter()
        
        if mode == .Time {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "dd MM YYYY"
            dateFormatter.locale = Locale(identifier: "ru_RU")
        }
        
        picker.date = dateFormatter.date(from: value) ?? Date()

    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum DatePickerMode {
        case Time
        case Date
        case DateFilter
        case None
    }
    
    var mode: DatePickerMode = .None
    var _id: String?
    var value: String?
    var completion: ((String, String) -> ())?
    
    lazy var picker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.locale = Locale(identifier: "ru_RU")
        if self.mode == .Time {
            picker.datePickerMode = .time
        } else if self.mode == .Date || self.mode == .DateFilter {
            picker.datePickerMode = .date
        }
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action:  #selector(save(_:)))
    }
    
    func getButtonTitle() -> String {
        if self.mode == .Time || self.mode == .Date {
            return "Сохранить"
        } else {
            return "Выбрать"
        }
    }
    
    @objc func save(_ sender: UIButton) {
        
        var value = ""
        
        if mode == .Time {
            let dateFormatr = DateFormatter()
            dateFormatr.dateFormat = "HH:mm"
            value = dateFormatr.string(from: (picker.date))
        } else {
            let dateFormatr = DateFormatter()
            dateFormatr.dateFormat = "dd MM YYYY"
            dateFormatr.locale = Locale(identifier: "ru_RU")
            value = dateFormatr.string(from: (picker.date))
        }
        
        guard let completion = completion, let _id = _id else { return }
        if self.mode == .DateFilter {
            completion(String(picker.date.timeIntervalSince1970), value)
        } else {
            completion(_id, value)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(picker)
        picker.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(200)
            make.left.equalTo(self.view.snp.left).offset(40)
            make.right.equalTo(self.view.snp.right).offset(-40)
            make.height.equalTo(200)
        })
    }
}
