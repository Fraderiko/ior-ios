//
//  OrderDetailsEmployee.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import MobileCoreServices

enum MediaFieldMode {
    case Image
    case Video
    case None
}

class MediaFieldViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MediaFieldViewModelDelegate, MediaCellDelegate {
    
    var mode: MediaFieldMode = .None
    var _id: String?
    var completion: ((String, [String]) -> ())?
    
    convenience init(_id: String, media: [String], mode: MediaFieldMode, title: String, completion: @escaping (String, [String]) -> ()) {
        self.init(nibName: nil, bundle: nil)
        self.mode = mode
        self.title = title
        self._id = _id
        
        var uploads: [Upload] = []
        for m in media {
            uploads.append(Upload(_id: "", url: m))
        }
        
        self.viewModel.uploads = uploads
        self.completion = completion
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var viewModel: MediaFieldViewModel = {
        let viewModel = MediaFieldViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MediaCell.self, forCellReuseIdentifier: NSStringFromClass(MediaCell.self))
        tableView.estimatedRowHeight = 48
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var picker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.delegate = self
        if self.mode == .Video {
            picker.mediaTypes = [kUTTypeMovie as String]
        }
        return picker
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
    }
    
    func setupViews() {
        view.addSubview(tableView)
        view.addSubview(saveButton)
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
        
        saveButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.height.equalTo(60)
        })
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Добавить", style: .plain, target: self, action:  #selector(add(_:)))
    }
    
    @objc func save(_ sender: UIButton) {
        
        let array = viewModel.uploads.map({ return $0.url })
        
        guard let completion = completion, let _id = _id else { return }
        completion(_id, array)
        navigationController?.popViewController(animated: true)
    }
    
    func mediaCellDidDeleteItem(index: Int) {
        viewModel.delete(index: index)
    }
    
    @objc func add(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "", message: "Выберите источник", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Камера", style: .default) { (action) in
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true, completion: nil)
        }
        let library = UIAlertAction(title: "Сохраненные", style: .default) { (action) in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        actionSheet.addAction(camera)
        actionSheet.addAction(library)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func urlsDidUpdated() {
        tableView.reloadData()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var imagePicked = false
        var videoPicked = false
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType == "public.image" {
                imagePicked = true
            }
            
            if mediaType == "public.movie" {
                videoPicked = true
            }
        }
        
        if mode == .Image && videoPicked == true {
            let alert = UIAlertController(title: "Ошибка", message: "В режиме фото нельзя выбирать видео", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        if mode == .Video && imagePicked == true {
            let alert = UIAlertController(title: "Ошибка", message: "В режиме видео нельзя выбирать фото", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
        if mode == .Image {
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage ?? UIImage()
            picker.dismiss(animated: true, completion: nil)
            
            viewModel.upload(mode: .Image, image: image, onProgress: { (progress) in
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showProgress(Float(progress), status:  String(format: "%.0f", progress * 100) + " %")
            }) { (success) in
                SVProgressHUD.dismiss()
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
                        SVProgressHUD.showProgress(Float(progress), status:  String(format: "%.0f" + " %", progress * 100)  + " %")
                    }, completion: { (success) in
                        SVProgressHUD.dismiss()
                    })
                } catch {
                    print(error)
                }
                
            }
        }
    }
}

extension MediaFieldViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mode == .Image {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MediaCell.self), for: indexPath) as? MediaCell else { return UITableViewCell() }
            cell.url = viewModel.uploads[indexPath.row].url
            cell.index = indexPath.row
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MediaCell.self), for: indexPath) as? MediaCell else { return UITableViewCell() }
            cell.index = indexPath.row
            cell.delegate = self
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.uploads.count
    }
}

protocol MediaCellDelegate: class {
    func mediaCellDidDeleteItem(index: Int)
}

class MediaCell: UITableViewCell {
    
    weak var delegate: MediaCellDelegate?
    
    var url: String? {
        didSet {
            guard let url = url else { return }
            let urlPath = URL(string: APIMode.Backend + url)
            self.img.sd_setImage(with: urlPath, completed: nil)
        }
    }
    
    var index: Int?
    
    lazy var img: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "play_video")
        return image
    }()
    
    lazy var deleteButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Удалить", for: .normal)
        button.addTarget(self, action: #selector(deleteDidTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteDidTapped(_ sender: UIButton) {
        guard let index = index else { return }
        delegate?.mediaCellDidDeleteItem(index: index)
    }
    
    func setupViews() {
        addSubview(img)
        addSubview(deleteButton)
        
        selectionStyle = .none
        
        img.snp.makeConstraints({make in
            make.left.equalTo(self.snp.left).offset(10)
            make.right.equalTo(self.snp.right).offset(-10)
            make.top.equalTo(self.snp.top).offset(10)
            make.height.equalTo(250)
        })
        
        deleteButton.snp.makeConstraints({make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalTo(self.img.snp.bottom).offset(10)
            make.bottom.equalTo(self.snp.bottom).offset(-10)
        })
    }
}
