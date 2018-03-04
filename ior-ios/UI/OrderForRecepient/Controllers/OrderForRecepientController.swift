//
//  OrderForRecepientController.swift
//  ior-ios
//
//  Created by me on 28/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import BRYXBanner
import OneSignal
import SVProgressHUD

class OrderForRecepientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CollectionViewCellDelegate, TextViewCellDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    var order: Order?
    
    lazy var viewModel: OrderForRecepientViewModel = {
        return OrderForRecepientViewModel()
    }()
    
    lazy var createViewModel: CreateDiscussionViewModel = {
        return CreateDiscussionViewModel()
    }()
    
    lazy var mediaViewModel: MediaFieldViewModel = {
        return MediaFieldViewModel()
    }()
    
    var mode: MediaFieldMode = MediaFieldMode.None
    
    var collectionViewDataSource: [UIImage] = []
    
    lazy var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TextCell.self, forCellReuseIdentifier: NSStringFromClass(TextCell.self))
        tableView.register(CollectionViewCell.self, forCellReuseIdentifier: NSStringFromClass(CollectionViewCell.self))
        tableView.register(TextViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextViewCell.self))
        tableView.estimatedRowHeight = 48
        return tableView
    }()
    
    lazy var picker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getOrder()
        
        setupPush()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Выход", style: .plain, target: self, action: #selector(logout))
    }
    
    func setupPush() {
        if Settings.pushId() == nil || Settings.pushId() == "" {
            let status = OneSignal.getPermissionSubscriptionState()
            let userId = status?.subscriptionStatus.userId ?? ""
            Settings.savePushID(id: userId)
            print("User push ID: \(userId)")
            
            viewModel.setUserPushID(push_id: userId)
        }
    }
    
    func getOrder() {
        viewModel.getOrder { (order) in
            self.title = "Заказ №" + order.number
            self.order = self.viewModel.prepare(order: order)
            self.tableView.reloadData()
        }
    }
    
    func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        })
    }
    
    @objc func logout() {
        if let bundle = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundle)
        }
        let controller = LoginViewController()
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func addMessage() {
        let controller = CreateDiscussionViewController()
        controller.order = order
        controller.completion = {
            let banner = Banner(title: "Сообщение успешно отправлено", subtitle: "", image: nil, backgroundColor: UIColor.blue)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            return
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let order = order else { return 0 }
        var sectionForDiscussion = 1
        var sectionForMessage = 1
        return order.statuses.count + sectionForDiscussion + sectionForMessage
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let order = order else { return 0 }
        
        if section == 0 {
            if order.discussion.isEmpty {
                return 0
            } else {
                return 1
            }
        }
        
        if section != 0 && section != tableView.numberOfSections - 1 {
            return order.statuses[section - 1].fields.count
        } else {
            return 1 // секция для сообщения
        }

    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let order = order else { return UITableViewCell() }
        
        let numberOfSection = 0
        
        if indexPath.section == 0 {
            if order.discussion.isEmpty == false {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
                cell.textLabel?.text = "Сообщений по заказу"
                cell.detailTextLabel?.text = String(order.discussion.count)
                return cell
            } else {
                return UITableViewCell()
            }
        } else if indexPath.section != tableView.numberOfSections - 1 {

            let section = indexPath.section - 1
            
            let field = order.statuses[section].fields[indexPath.row]
            if field.type == "text" || field.type == "digit" || field.type == "date" || field.type == "time" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextCell.self), for: indexPath) as? TextCell else { return UITableViewCell() }
                cell.textLabel?.text = order.statuses[section].fields[indexPath.row].name
                cell.detailTextLabel?.text = order.statuses[section].fields[indexPath.row].value
                return cell
            } else if field.type == "image" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CollectionViewCell.self), for: indexPath) as? CollectionViewCell else { return UITableViewCell()}
                cell.type = CollectionViewCellType.Image
                cell.urls = field.media
                cell.delegate = self
                cell.index = indexPath.row
                cell.section = section
                return cell
            } else if field.type == "video" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CollectionViewCell.self), for: indexPath) as? CollectionViewCell else { return UITableViewCell()}
                cell.type = CollectionViewCellType.Video
                cell.urls = field.media
                cell.delegate = self
                cell.index = indexPath.row
                cell.section = section
                return cell
            } else {
                return UITableViewCell()
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TextViewCell.self), for: indexPath) as? TextViewCell else { return UITableViewCell() }
            cell.viewModel = mediaViewModel
            cell.delegate = self
            cell.collectionViewDataSource = collectionViewDataSource
            cell.order = order
            cell.completion = {
                let banner = Banner(title: "Сообщение успешно отправлено", subtitle: "", image: nil, backgroundColor: UIColor.blue)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.collectionViewDataSource = []
                self.getOrder()

            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let order = order else { return }
        if indexPath.section == 0 {
            let controller = DiscussionViewController()
            controller.discussions = order.discussion
            controller.order = order
            controller.completion = {
                let banner = Banner(title: "Сообщение успешно отправлено", subtitle: "", image: nil, backgroundColor: UIColor.blue)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.getOrder()
            }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let order = order else { return 0 }
        
        if order.discussion.isEmpty == false {
            if indexPath.section != 0 {
                if indexPath.section != tableView.numberOfSections - 1 {
                    let field = order.statuses[indexPath.section - 1].fields[indexPath.row]
                    if field.type == "video" || field.type == "image" {
                        return 100
                    } else {
                        return UITableViewAutomaticDimension
                    }
                } else {
                    return UITableViewAutomaticDimension
                }
            }
        } else {
            if indexPath.section != 0 {
                if indexPath.section != tableView.numberOfSections - 1 {
                    let field = order.statuses[indexPath.section - 1].fields[indexPath.row]
                    if field.type == "video" || field.type == "image" {
                        return 100
                    } else {
                        return UITableViewAutomaticDimension
                    }
                } else {
                    return UITableViewAutomaticDimension
                }
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    func collectionViewItemDidTapped(item: Int, section: Int?, index: Int, type: CollectionViewCellType) {
        guard let order = order, let section = section else { return }
        if type == .Video {
            guard let url = URL(string: APIMode.Backend + order.statuses[section].fields[index].media[item]) else { return }
            
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
            controller.urls = order.statuses[section].fields[index].media
            controller.startingIndex = item
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func textViewCellWantDeleteMedia(index: Int) {
        let alert = UIAlertController(title: "Удалить?", message: "", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Да", style: .destructive) { (action) in
            
            guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.tableView.numberOfSections - 1)) as? TextViewCell else { return }
            
            if let video_index = cell.viewModel.video_urls.index(where: { $0 == cell.viewModel.uploads[index].url}) {
                cell.viewModel.video_urls.remove(at: video_index)
            }
            
            if let image_index = cell.viewModel.photo_urls.index(where: { $0 == cell.viewModel.uploads[index].url }) {
                cell.viewModel.photo_urls.remove(at: image_index)
            }
            
            self.collectionViewDataSource.remove(at: index)
            cell.viewModel.uploads.remove(at: index)
            cell.collectionView.reloadData()
            self.tableView.reloadData()
        }
        let no = UIAlertAction(title: "Нет", style: .default, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if mode == .Image {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage ?? UIImage()
            picker.dismiss(animated: true, completion: nil)
            
            mediaViewModel.upload(mode: .Image, image: image, onProgress: { (progress) in
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showProgress(Float(progress))
            }) { (success) in
                SVProgressHUD.dismiss()
                self.collectionViewDataSource.append(image)
                self.tableView.reloadData()
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
                    
                    mediaViewModel.upload(mode: .Video, videoURL: url, image: nil, onProgress: { (progress) in
                        SVProgressHUD.setDefaultMaskType(.black)
                        SVProgressHUD.showProgress(Float(progress))
                    }, completion: { (success) in
                        SVProgressHUD.dismiss()
                        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: self.tableView.numberOfSections - 1)) as? TextViewCell else { return }
                        self.collectionViewDataSource.append(UIImage(named:"play_video") ?? UIImage())
                        self.tableView.reloadData()
                    })
                } catch {
                    print(error)
                }
                
            }
        }
    }
    
    func textViewCellWantAddVideo() {
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
    
    func textViewCellWantAddPhoto() {
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
}

protocol TextViewCellDelegate: class {
    func textViewCellWantDeleteMedia(index: Int)
    func textViewCellWantAddVideo()
    func textViewCellWantAddPhoto()
}

class TextViewCell: UITableViewCell, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var delegate: TextViewCellDelegate?
    
    var collectionViewDataSource: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var order: Order?
    
    lazy var viewModel: MediaFieldViewModel = {
        var viewModel = MediaFieldViewModel()
        return viewModel
    }()
    
    lazy var createViewModel: CreateDiscussionViewModel = {
        return CreateDiscussionViewModel()
    }()
    
    var completion: (() -> ())?
    
    lazy var label: UILabel = {
        var label = UILabel()
        label.text = "Форма обратной связи"
        return label
    }()
    
    lazy var deleteLabel: UILabel = {
        var label = UILabel()
        label.text = "Нажмите на иконку файла, чтобы удалить"
        label.textColor = UIColor.lightGray.withAlphaComponent(0.5)
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.isHidden = true
        return label
    }()
    
    lazy var textView: UITextView = {
        var textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 75, height: 50)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.backgroundView = UIView()
        collectionView.register(CollectionViewMediaCell.self, forCellWithReuseIdentifier: NSStringFromClass(CollectionViewMediaCell.self))
        return collectionView
    }()
    
    lazy var textViewPlaceholder: UILabel = {
        var label = UILabel()
        label.text = "Ваше сообщение"
        label.textColor = UIColor.lightGray.withAlphaComponent(0.3)
        return label
    }()
    
    lazy var addPhotoButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage(named: "photo") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        return button
    }()
    
    lazy var addVideoButton: UIButton = {
        var button = UIButton(type: .system)
        button.setImage(UIImage(named: "video") ?? UIImage(), for: .normal)
        button.addTarget(self, action: #selector(addVideo), for: .touchUpInside)
        return button
    }()
    
    lazy var sendButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Отправить", for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        return button
    }()
    
    lazy var separator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addPhoto() {
        delegate?.textViewCellWantAddPhoto()
    }
    
    @objc func addVideo() {
        delegate?.textViewCellWantAddVideo()
    }
    
    override func prepareForReuse() {
        collectionViewDataSource = []
    }
    
    func setupViews() {
        addSubview(textView)
        addSubview(label)
        textView.addSubview(textViewPlaceholder)
        addSubview(collectionView)
        addSubview(addPhotoButton)
        addSubview(addVideoButton)
        addSubview(deleteLabel)
        addSubview(sendButton)
        addSubview(separator)
        
        textView.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(10)
            make.right.equalTo(self.snp.right).offset(-10)
            make.top.equalTo(self.label.snp.bottom).offset(10)
            make.height.equalTo(200)
        })
        
        textViewPlaceholder.snp.makeConstraints({ make in
            make.left.equalTo(textView.snp.left).offset(8)
            make.top.equalTo(textView.snp.top).offset(6)
        })
        
        label.snp.makeConstraints({ make in
            make.top.equalTo(self.snp.top).offset(10)
            make.left.equalTo(self.snp.left).offset(10)
        })
        
        
        addPhotoButton.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(10)
            make.top.equalTo(self.textView.snp.bottom).offset(10)
        })
        
        addVideoButton.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-10)
            make.top.equalTo(self.addPhotoButton.snp.top)
        })
        
        collectionView.snp.makeConstraints({ make in
            make.top.equalTo(self.addPhotoButton.snp.bottom).offset(20)
            make.left.equalTo(self.snp.left).offset(20)
            make.right.equalTo(self.snp.right).offset(-20)
            make.height.equalTo(50)
        })
        
        
        deleteLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(10)
            make.top.equalTo(self.addPhotoButton.snp.bottom).offset(1)
        })
        
        sendButton.snp.makeConstraints({ make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.collectionView.snp.bottom).offset(10)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        })
        
        separator.snp.makeConstraints({ make in
            make.height.equalTo(1)
            make.left.equalTo(self.textView.snp.left)
            make.right.equalTo(self.textView.snp.right)
            make.top.equalTo(self.collectionView.snp.top).offset(-4)
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.textViewPlaceholder.alpha = textView.text.isEmpty ? 1 : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        deleteLabel.isHidden = collectionViewDataSource.isEmpty
        return collectionViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CollectionViewMediaCell.self), for: indexPath) as? CollectionViewMediaCell else { return UICollectionViewCell()}
        cell.img.contentMode = .scaleAspectFit
        cell.set(image: collectionViewDataSource[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.textViewCellWantDeleteMedia(index: indexPath.item)
    }
    
    @objc func send() {
        guard let text = textView.text, let order = order, let completion = completion else { return }
        if text.isEmpty {
            let banner = Banner(title: "Сообщение не может быть пустым", subtitle: "", image: nil, backgroundColor: UIColor.red)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            return
        }

        let discussion = Discussion(date: Double(Int(Date().timeIntervalSince1970.rounded())), message: text, image_media: viewModel.photo_urls, video_media: viewModel.video_urls, author: Settings.userId() ?? "")

        createViewModel.send(_id: order._id, discussion: discussion) {
            self.textView.text = ""
            self.collectionViewDataSource = []
            completion()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
