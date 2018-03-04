//
//  CreateDiscussionViewController.swift
//  ior-ios
//
//  Created by me on 29/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import MobileCoreServices
import BRYXBanner

class CreateDiscussionViewController: UIViewController, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var order: Order?
    
    var mode: MediaFieldMode = .None
    
    var collectionViewDataSource: [UIImage] = []
    var completion: (() -> ())?
    
    lazy var viewModel: MediaFieldViewModel = {
        var viewModel = MediaFieldViewModel()
        return viewModel
    }()
    
    lazy var createViewModel: CreateDiscussionViewModel = {
        return CreateDiscussionViewModel()
    }()
    
    lazy var textView: UITextView = {
        var textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.delegate = self
        textView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        return textView
    }()
    
    lazy var textViewPlaceholder: UILabel = {
        var label = UILabel()
        label.text = "Ваше сообщение"
        label.textColor = UIColor.lightGray.withAlphaComponent(0.3)
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
    
    lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 75, height: 75)
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
    
    lazy var picker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.delegate = self
        if self.mode == .Video {
            picker.mediaTypes = [kUTTypeMovie as String]
        }
        return picker
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
    
    lazy var separator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отправить", style: .plain, target: self, action: #selector(send))
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
            self.navigationController?.popToRootViewController(animated: true)
            completion()
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
                self.collectionViewDataSource.append(image)
                self.collectionView.reloadData()
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
                        self.collectionViewDataSource.append(UIImage(named:"play_video") ?? UIImage())
                        self.collectionView.reloadData()
                    })
                } catch {
                    print(error)
                }
                
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.textViewPlaceholder.alpha = textView.text.isEmpty ? 1 : 0
        }
    }
    
    func setupViews() {
        view.backgroundColor = .white

        
        view.addSubview(textView)
        view.addSubview(collectionView)
        textView.addSubview(textViewPlaceholder)
        view.addSubview(deleteLabel)
        view.addSubview(addPhotoButton)
        view.addSubview(addVideoButton)
        view.addSubview(separator)
        
        textView.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(70)
            make.left.equalTo(self.view.snp.left).offset(20)
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.height.equalTo(200)
        })
        
        textViewPlaceholder.snp.makeConstraints({ make in
            make.left.equalTo(textView.snp.left).offset(8)
            make.top.equalTo(textView.snp.top).offset(10)
        })
        
        addPhotoButton.snp.makeConstraints({ make in
            make.left.equalTo(self.textView.snp.left)
            make.top.equalTo(self.textView.snp.bottom).offset(5)
        })
        
        addVideoButton.snp.makeConstraints({ make in
            make.right.equalTo(self.view.snp.right).offset(-10)
            make.top.equalTo(self.addPhotoButton.snp.top)
        })
        
        collectionView.snp.makeConstraints({ make in
            make.top.equalTo(self.addVideoButton.snp.bottom).offset(10)
            make.left.equalTo(self.view.snp.left).offset(20)
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.height.equalTo(100)
        })
        
        deleteLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.collectionView.snp.left)
            make.bottom.equalTo(self.separator.snp.top).offset(-2)
        })
        
        separator.snp.makeConstraints({ make in
            make.height.equalTo(1)
            make.left.equalTo(self.textView.snp.left)
            make.right.equalTo(self.textView.snp.right)
            make.top.equalTo(self.collectionView.snp.top).offset(3)
        })
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
        let alert = UIAlertController(title: "Удалить?", message: "", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Да", style: .destructive) { (action) in
            if let video_index = self.viewModel.video_urls.index(where: { $0 == self.viewModel.uploads[indexPath.item].url}) {
                self.viewModel.video_urls.remove(at: video_index)
            }
            
            if let image_index = self.viewModel.photo_urls.index(where: { $0 == self.viewModel.uploads[indexPath.item].url }) {
                self.viewModel.photo_urls.remove(at: image_index)
            }
            
            self.collectionViewDataSource.remove(at: indexPath.item)
            self.viewModel.uploads.remove(at: indexPath.item)
            self.collectionView.reloadData()
        }
        let no = UIAlertAction(title: "Нет", style: .default, handler: nil)
        alert.addAction(yes)
        alert.addAction(no)
        self.present(alert, animated: true, completion: nil)
    }
}

class CollectionViewMediaCell: CollectionViewVideoCell {
    
    func set(image: UIImage) {
        self.img.image = image
    }
}
