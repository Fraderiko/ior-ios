//
//  OrderDetailsEmployee.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import BRYXBanner

class FillNewStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var status: Status?
    var order: Order?
    var completion: (() -> ())?
    
    lazy var viewModel: FillNewStatusViewModel = {
        return FillNewStatusViewModel()
    }()
    
    var isStatusHidden: Bool = false {
        didSet {
            if isStatusHidden == true {
                tableView.isHidden = true
                saveButton.isHidden = true
            }
        }
    }
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CollectionViewCell.self, forCellReuseIdentifier: NSStringFromClass(CollectionViewCell.self))
        tableView.register(TextCell.self, forCellReuseIdentifier: NSStringFromClass(TextCell.self))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    lazy var hiddenLabel: UILabel = {
        var label = UILabel()
        label.text = "Для заполнения данного статуса необходимо заполнить предыдущий"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var saveButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = status?.name
        
        if (status?.groups_permission_to_edit ?? [] == [] && status?.users_permission_to_edit ?? [] == []) {
            setupViews()
        } else if (status?.users_permission_to_edit.contains(Settings.userId() ?? "") ?? false) {
            setupViews()
        } else {
            APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/egroup-user", parameters: ["user" : Settings.userId() ?? "", "groups" : status?.groups_permission_to_edit ?? []]) { (response, error) in
                guard let response = response as? [String: Bool] else { return }
                if response["result"] == true {
                    self.setupViews()
                } else {
                    
                    let alert = UIAlertController(title: "Статус недоступен", message: "Нет прав для заполнения статуса", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ок", style: UIAlertActionStyle.default, handler: { void in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)

                }
            }
        }
        
        
    }
    
    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(hiddenLabel)
        view.addSubview(tableView)
        view.addSubview(saveButton)
        
        hiddenLabel.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            make.width.equalTo(200)
        })
        
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
        
        saveButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.height.equalTo(60)
        })
    }
    
    @objc func save(_ sender: UIButton) {
        guard let order = order, let status = status else { return }
        status.state = "preFilled"
        viewModel.update(order: order) { (success, fields) in
            if success == false {
                let banner = Banner(title: "Ошибка! Заполните поля:", subtitle: fields, image: nil, backgroundColor: UIColor.red)
                banner.dismissesOnTap = true
                banner.show(duration: 5.0)
            } else {
                guard let completion = self.completion else { return }
                completion()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let status = status else { return UITableViewCell() }
        
        if status.fields[indexPath.row].type == "text" || status.fields[indexPath.row].type == "digit" || status.fields[indexPath.row].type == "time" || status.fields[indexPath.row].type == "date" {
            if status.fields[indexPath.row].value == "" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as? UITableViewCell else { return UITableViewCell() }
                
                if status.fields[indexPath.row].required == true {
                    cell.textLabel?.text = status.fields[indexPath.row].name + " (*)"

                } else {
                    cell.textLabel?.text = status.fields[indexPath.row].name
                }
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
                cell.textLabel?.text = status.fields[indexPath.row].name
                cell.detailTextLabel?.text = status.fields[indexPath.row].value
                return cell
            }
        } else if status.fields[indexPath.row].type == "image" || status.fields[indexPath.row].type == "video" {
            if status.fields[indexPath.row].media.isEmpty {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath) as? UITableViewCell else { return UITableViewCell() }
                
                if status.fields[indexPath.row].required == true {
                    cell.textLabel?.text = status.fields[indexPath.row].name + " (*)"
                    
                } else {
                    cell.textLabel?.text = status.fields[indexPath.row].name
                }
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
                
                if status.fields[indexPath.row].required == true {
                    cell.textLabel?.text = status.fields[indexPath.row].name + " (*)"
                    
                } else {
                    cell.textLabel?.text = status.fields[indexPath.row].name
                }
                
                cell.detailTextLabel?.text = "Выбрано \(status.fields[indexPath.row].media.count)"
                return cell
            }
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let status = status else { return }
        if status.fields[indexPath.row].type == "digit" {
            let controller = TextFieldViewController(_id: status.fields[indexPath.row]._id, value: status.fields[indexPath.row].value, mode: .Digits, title: status.fields[indexPath.row].name, completion: { (_id, value) in
                guard let index = status.fields.index(where: { $0._id == _id }) else { return }
                status.fields[index].value = value
                tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if status.fields[indexPath.row].type == "text"  {
            let controller = TextFieldViewController(_id: status.fields[indexPath.row]._id, value: status.fields[indexPath.row].value, mode: .Text, title: status.fields[indexPath.row].name, completion: { (_id, value) in
                guard let index = status.fields.index(where: { $0._id == _id }) else { return }
                status.fields[index].value = value
                tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if status.fields[indexPath.row].type == "date"  {
            let controller = DatePickerViewController(_id: status.fields[indexPath.row]._id, value: status.fields[indexPath.row].value, mode: .Date, title: status.fields[indexPath.row].name, completion: { (_id, value) in
                guard let index = status.fields.index(where: { $0._id == _id }) else { return }
                status.fields[index].value = value
                tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if status.fields[indexPath.row].type == "time"  {
            let controller = DatePickerViewController(_id: status.fields[indexPath.row]._id, value: status.fields[indexPath.row].value, mode: .Time, title: status.fields[indexPath.row].name, completion: { (_id, value) in
                guard let index = status.fields.index(where: { $0._id == _id }) else { return }
                status.fields[index].value = value
                tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if status.fields[indexPath.row].type == "image" {
            let controller = MediaFieldViewController(_id: status.fields[indexPath.row]._id, media: status.fields[indexPath.row].media, mode: .Image, title: status.fields[indexPath.row].name, completion: { (_id, media) in
                guard let index = status.fields.index(where: { $0._id == _id }) else { return }
                status.fields[index].media = media
                tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
        
        if status.fields[indexPath.row].type == "video" {
            let controller = MediaFieldViewController(_id: status.fields[indexPath.row]._id, media: status.fields[indexPath.row].media, mode: .Video, title: status.fields[indexPath.row].name, completion: { (_id, media) in
                guard let index = status.fields.index(where: { $0._id == _id }) else { return }
                status.fields[index].media = media
                tableView.reloadData()
            })
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let status = status else { return 0 }
        return status.fields.count
    }
}
