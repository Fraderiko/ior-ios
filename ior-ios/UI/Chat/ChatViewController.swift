//
//  ChatViewController.swift
//  ior-ios
//
//  Created by Alexey on 24/01/2018.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import MobileCoreServices

class ChatViewController: DiscussionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, InputContainerDelegate {
    
    var orderID: String?
    var orderNumber: String?
    var names: [String: String] = [:]
    
    override func viewDidLoad() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        tabBarController?.tabBar.isHidden = true
        setupViews()
        SocketsService.shared.updateOrderCompletion = { (_id, message) in
            if _id == self.orderID ?? "" {
                self.order?.messages.append(message)
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(item: self.tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        APIManager.shared.getRequest(mode: APIMode.Backend, endPoint: "/order/\(orderNumber ?? "")") { (response, error) in
            guard let response = response as? [String: Any] else {
                return
            }
            
            let jsonData = try! JSONSerialization.data(withJSONObject: response, options: [])
            let jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
            let data = jsonString.data(using: .utf8)
            
            do {
                var order = try JSONDecoder().decode(Order.self, from: data!)
                self.order = order
                self.tableView.reloadData()
                
                if order.messages.isEmpty == false {
                    self.tableView.scrollToRow(at: IndexPath(item: self.tableView.numberOfRows(inSection: 0) - 1, section: 0), at: .bottom, animated: true)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = sender.userInfo {
            let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue.size.height
            tableView.snp.updateConstraints({ make in
                make.bottom.equalTo(self.view.snp.bottom).offset(-keyboardHeight)
            })
            animate()
        }
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        tableView.snp.updateConstraints({ make in
            make.bottom.equalTo(self.view.snp.bottom).offset(-40)
        })
        animate()
    }
    
    func animate(completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.layoutIfNeeded()
        }) { (success) in
            if let completion = completion {
                completion(success)
            }
        }
    }
    
    var mode: MediaFieldMode = .None
    
    lazy var container: InputContainer = {
        var view = InputContainer(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        view.delegate = self
        return view
    }()
    
    lazy var viewModel: MediaFieldViewModel = {
        var viewModel = MediaFieldViewModel()
        return viewModel
    }()
    
    lazy var picker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.delegate = self
        if self.mode == .Video {
            picker.mediaTypes = [kUTTypeMovie as String]
        }
        return picker
    }()
    
    override func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom).offset(-40)
        })
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return container
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let order = order else { return 0 }
        return order.messages.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let order = order else { return UITableViewCell() }
        let message = order.messages[indexPath.row]
        let discussion = DiscussionObject(type: getType(message: message), value: message.value, author: message.username)
        
        if discussion.type == .Text {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DiscussionTextCell.self), for: indexPath) as? DiscussionTextCell else { return UITableViewCell() }
            cell.discussion = discussion
            cell.dateLabel.text = Date(timeIntervalSince1970: order.messages[indexPath.row].date / 1000).formattedDate()
            cell.index = indexPath.row
            cell.userLabel.text = names[message.username]
            
            if discussion.author == Settings.userId() ?? "" {
                cell.setupRight()
            } else {
                cell.setupLeft()
            }
            
//            APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(message.username)", completion: { (response, error) in
//                guard let response = response as? [String: Any] else { return }
//                var name = response["name"] as? String ?? ""
//                cell.userLabel.text = name
//            })
            
            return cell
        } else if discussion.type == .Image {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DiscussionImageCell.self), for: indexPath) as? DiscussionImageCell else { return UITableViewCell() }
            cell.discussion = discussion
            cell.index = indexPath.row
            cell.section = indexPath.section
            cell.delegate = self
            cell.userLabel.text = names[message.username]
            
            if discussion.author == Settings.userId() ?? "" {
                cell.setupRight()
            } else {
                cell.setupLeft()
            }
            
//            APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(message.username)", completion: { (response, error) in
//                guard let response = response as? [String: Any] else { return }
//                var name = response["name"] as? String ?? ""
//                cell.userLabel.text = name
//            })
            
            cell.dateLabel.text = Date(timeIntervalSince1970: order.messages[indexPath.row].date / 1000).formattedDate()

            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DiscussionVideoCell.self), for: indexPath) as? DiscussionVideoCell else { return UITableViewCell() }
            cell.discussion = discussion
            cell.index = indexPath.row
            cell.section = indexPath.section
            cell.delegate = self
            cell.dateLabel.text = Date(timeIntervalSince1970: order.messages[indexPath.row].date / 1000).formattedDate()
            cell.userLabel.text = names[message.username]

//            APIManager.shared.postRequest(mode: APIMode.Backend, endPoint: "/user/\(message.username)", completion: { (response, error) in
//                guard let response = response as? [String: Any] else { return }
//                var name = response["name"] as? String ?? ""
//                cell.userLabel.text = name
//            })
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func getType(message: Message) -> DiscussionObjectType {
        switch message.type {
        case "TEXT":
            return .Text
        case "VIDEO":
            return .Video
        case "IMAGE":
            return .Image
        default:
            return .Text
        }
    }
    
    @objc func sendText() {
        
    }
    
    
    func photoButtonPressed() {
        addPhoto()
    }
    
    func videoButtonPressed() {
        addVideo()
    }
    
    func textButtonPressed(text: String) {
        if text.isEmpty == false {
            let message = Message(order: self.order?._id ?? "", username: Settings.userId() ?? "", type: "TEXT", value: text, date: Double(Int(Date().timeIntervalSince1970.rounded()) * 1000))
            SocketsService.shared.post(message: message)
        }
    }
    
    @objc func addVideo() {
        
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "Выберите источник", message: nil, preferredStyle: .actionSheet)
        let photo = UIAlertAction(title: "Камера", style: .default) { (action) in
            self.mode = .Video
            self.picker.mediaTypes = [kUTTypeMovie as String]
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        }
        let video = UIAlertAction(title: "Сохраненные", style: .default) { (action) in
            self.mode = .Video
            self.picker.mediaTypes = [kUTTypeMovie as String]
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }
        
        alert.addAction(photo)
        alert.addAction(video)
        present(alert, animated: false, completion: nil)
        
    }
    
    @objc func addPhoto() {
        
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "Выберите источник", message: nil, preferredStyle: .actionSheet)
        let photo = UIAlertAction(title: "Камера", style: .default) { (action) in
            self.mode = .Image
            self.picker.mediaTypes = [kUTTypeImage as String]
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        }
        let video = UIAlertAction(title: "Сохраненные", style: .default) { (action) in
            self.mode = .Image
            self.picker.mediaTypes = [kUTTypeImage as String]
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }
        
        alert.addAction(photo)
        alert.addAction(video)
        present(alert, animated: false, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if mode == .Image {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage ?? UIImage()
            picker.dismiss(animated: true, completion: nil)
            
            viewModel.upload(mode: .Image, image: image, onProgress: { (progress) in
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showProgress(Float(progress))
            }) { (success) in
                SVProgressHUD.dismiss()
                let message = Message(order: self.order?._id ?? "", username: Settings.userId() ?? "", type: "IMAGE", value: self.viewModel.photo_urls[0], date: Double(Int(Date().timeIntervalSince1970.rounded()) * 1000))
                SocketsService.shared.post(message: message)
                self.viewModel.photo_urls.removeAll()
            }
        } else {
            if let pickedVideo = info[UIImagePickerControllerMediaURL] as? URL {
                
                let videoData : Data!
                do {
                    try videoData = Data(contentsOf: pickedVideo as URL)
                    var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                    let documentsDirectory = paths[0]
                    let tempPath = documentsDirectory.appendingFormat("/video.mov")
                    let url = URL(fileURLWithPath: tempPath)
                    do {
                        try _ = videoData.write(to: url, options: [])
                    } catch {
                        print(error)
                    }
                    
                    picker.dismiss(animated: true, completion: nil)
                    
                    viewModel.upload(mode: .Video, videoURL: url, image: nil, onProgress: { (progress) in
                        SVProgressHUD.setDefaultMaskType(.black)
                        SVProgressHUD.showProgress(Float(progress))
                    }, completion: { (success) in
                        SVProgressHUD.dismiss()
                        let message = Message(order: self.order?._id ?? "", username: Settings.userId() ?? "", type: "VIDEO", value: self.viewModel.video_urls[0], date: Double(Int(Date().timeIntervalSince1970.rounded()) * 1000))
                        SocketsService.shared.post(message: message)
                        self.viewModel.video_urls.removeAll()
                    })
                } catch {
                    print(error)
                }
                
            }
        }
    }
}

protocol InputContainerDelegate: class {
    func photoButtonPressed()
    func videoButtonPressed()
    func textButtonPressed(text: String)
}

class InputContainer: UIView  {
    
    weak var delegate: InputContainerDelegate?
    
    lazy var textField: UITextField = {
        var view = UITextField(frame: CGRect(x: 5, y: 5, width: 200, height: 30))
        view.borderStyle = .roundedRect
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: 210, y: 5, width: 80, height: 30))
        button.addTarget(self, action: #selector(sendText), for: .touchUpInside)
        button.setTitle("Отправить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return button
    }()
    
    lazy var imageButton: UIButton = {
        let imageButton = UIButton(frame: CGRect(x: 300, y: 5, width: 25, height: 25))
        imageButton.setImage(UIImage(named: "photo") ?? UIImage(), for: .normal)
        imageButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        return imageButton
    }()
    
    lazy var videoButton: UIButton = {
        let videoButton = UIButton(frame: CGRect(x: 340, y: 5, width: 25, height: 25))
        videoButton.setImage(UIImage(named: "video") ?? UIImage(), for: .normal)
        videoButton.addTarget(self, action: #selector(addVideo), for: .touchUpInside)
        return videoButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.lightGray

        
        addSubview(videoButton)
        addSubview(imageButton)
        addSubview(button)
        addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addVideo() {
        delegate?.videoButtonPressed()
    }
    
    @objc func addPhoto() {
        delegate?.photoButtonPressed()
    }
    
    @objc func sendText() {
        delegate?.textButtonPressed(text: textField.text ?? "")
        textField.text = ""
    }
}

