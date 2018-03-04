//
//  OrderDetailsViewController.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVKit
import AVFoundation

class FilledStatusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CollectionViewCellDelegate {
    
    var status: Status?
    var userCanEditOrder: Bool = false
    var editBlock: ((Status, Int)-> ())?
    var index: Int?
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CollectionViewCell.self, forCellReuseIdentifier: NSStringFromClass(CollectionViewCell.self))
        tableView.register(TextCell.self, forCellReuseIdentifier: NSStringFromClass(TextCell.self))
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    lazy var editButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Редактировать", for: .normal)
        button.addTarget(self, action: #selector(commitEditOrder), for: .touchUpInside)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        title = status?.name
    }
    
    func setupViews() {
        view.addSubview(tableView)
        view.addSubview(editButton)
        
        editButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.height.equalTo(60)
        })
        
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
    }
    
    @objc func commitEditOrder() {
        if let editBlock = editBlock, let index = index, let status = status {
            editBlock(status, index)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func collectionViewItemDidTapped(item: Int, section: Int?, index: Int, type: CollectionViewCellType) {
        guard let status = status else { return }
        
        if userCanEditOrder == true {
            tableView(self.tableView, didSelectRowAt: IndexPath(row: index, section: 0))
            return
        }
        
        if type == .Video {
            
            guard let url = URL(string: APIMode.Backend + status.fields[index].media[item]) else { return }
            
            let asset = AVAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            
            let player = AVPlayer(playerItem: item)
            
            let playerController = AVPlayerViewController()
            
            playerController.player = player
            self.addChildViewController(playerController)
            self.view.addSubview(playerController.view)
            
            navigationController?.pushViewController(playerController, animated: true)
            
            player.play()
        } else {
            let controller = ImageGalleryViewController()
            controller.urls = status.fields[index].media
            controller.startingIndex = item
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

extension FilledStatusViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let status = status else { return UITableViewCell() }
        if status.fields[indexPath.row].type == "text" || status.fields[indexPath.row].type == "digit" || status.fields[indexPath.row].type == "time" || status.fields[indexPath.row].type == "date" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
            cell.textLabel?.text = status.fields[indexPath.row].name
            cell.detailTextLabel?.text = status.fields[indexPath.row].value
            
            if userCanEditOrder {
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        } else if status.fields[indexPath.row].type == "image" {
            
            if userCanEditOrder {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
                
                cell.textLabel?.text = status.fields[indexPath.row].name
                cell.detailTextLabel?.text = String(status.fields[indexPath.row].media.count)
                
                if userCanEditOrder {
                    cell.accessoryType = .disclosureIndicator
                }
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CollectionViewCell.self), for: indexPath) as? CollectionViewCell else { return UITableViewCell()}
                cell.type = CollectionViewCellType.Image
                cell.urls = status.fields[indexPath.row].media
                cell.delegate = self
                cell.index = indexPath.row
                cell.accessoryType = .disclosureIndicator
                
                return cell
            }
            
            
        } else if status.fields[indexPath.row].type == "video" {
            
            if userCanEditOrder {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
                
                cell.textLabel?.text = status.fields[indexPath.row].name
                cell.detailTextLabel?.text = String(status.fields[indexPath.row].media.count)
                cell.accessoryType = .disclosureIndicator
                
                return cell
                
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CollectionViewCell.self), for: indexPath) as? CollectionViewCell else { return UITableViewCell()}
                cell.type = CollectionViewCellType.Video
                cell.urls = status.fields[indexPath.row].media
                cell.delegate = self
                cell.index = indexPath.row
                return cell
            }
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let status = status else { return 0 }
        if status.fields[indexPath.row].type == "image" || status.fields[indexPath.row].type == "video" {
            return 100
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let status = status else { return 0 }
        return status.fields.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if userCanEditOrder {
            
            if userCanEditOrder == true {
                editButton.isHidden = false
            }
            
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
    }
    
}









