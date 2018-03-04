//
//  DiscussionViewController.swift
//  ior-ios
//
//  Created by me on 29/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import BRYXBanner

class DiscussionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DiscussionImageCellDelegate, DiscussionVideoCellDelegate {
    
    var discussions: [Discussion] = []
    var order: Order?
    var completion: (() -> ())?
    var preparedDiscussions: [[DiscussionObject]] = []
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.register(DiscussionTextCell.self, forCellReuseIdentifier: NSStringFromClass(DiscussionTextCell.self))
        tableView.register(DiscussionVideoCell.self, forCellReuseIdentifier: NSStringFromClass(DiscussionVideoCell.self))
        tableView.register(DiscussionImageCell.self, forCellReuseIdentifier: NSStringFromClass(DiscussionImageCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionFooterHeight = 48
        tableView.separatorStyle = .none
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        return tableView
    }()
    
    override func viewDidLoad() {
        setupViews()
        prepareDiscussions()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сообщение", style: .plain, target: self, action: #selector(addMessage))
    }
    
    func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ make in
            make.edges.equalTo(self.view)
        })
    }
    
    @objc func addMessage() {
        let controller = CreateDiscussionViewController()
        controller.order = order
        controller.completion = {
            if let completion = self.completion {
                completion()
            } else {
                let banner = Banner(title: "Сообщение успешно отправлено", subtitle: "", image: nil, backgroundColor: UIColor.blue)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                return
            }
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func discussionImageCellTapped(url: String) {
        let controller = ImageGalleryViewController()
        controller.urls = [url]
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func discussionVideoCellTapped(url: String) {
        guard let url = URL(string: APIMode.Backend + url) else { return }
        
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: item)
        
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        
        navigationController?.pushViewController(playerController, animated: true)
        
        player.play()
    }
    
    func collectionViewItemDidTapped(item: Int, section: Int?, index: Int, type: CollectionViewCellType) {
        if type == .Video {
            
        } else {
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preparedDiscussions[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return preparedDiscussions.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UILabel(frame: CGRect(x: self.view.frame.width, y: 0, width: 100, height: 30))
        view.textAlignment = .center
        view.text = Date(timeIntervalSince1970: discussions[section].date / 1000).formattedDate()
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func prepareDiscussions()  {

        for discussion in discussions {
            
            var array: [DiscussionObject] = []
            
            var text = discussion.message
            var object = DiscussionObject.init(type: .Text, value: text, author: discussion.author)
            array.append(object)
            
            for image in discussion.image_media {
                var object = DiscussionObject.init(type: .Image, value: image, author: discussion.author)
                array.append(object)
            }
            
            for video in discussion.video_media {
                var object = DiscussionObject.init(type: .Video, value: video, author: discussion.author)
                array.append(object)
            }
            
            preparedDiscussions.append(array)
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if preparedDiscussions[indexPath.section][indexPath.row].type == .Text {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DiscussionTextCell.self), for: indexPath) as? DiscussionTextCell else { return UITableViewCell() }
            cell.discussion = preparedDiscussions[indexPath.section][indexPath.row]
            cell.index = indexPath.row
            
            if preparedDiscussions[indexPath.section][indexPath.row].author == Settings.userId() ?? "" {
                cell.setupRight()
            } else {
                cell.setupLeft()
            }
            
            return cell
        } else if preparedDiscussions[indexPath.section][indexPath.row].type == .Image {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DiscussionImageCell.self), for: indexPath) as? DiscussionImageCell else { return UITableViewCell() }
            cell.discussion = preparedDiscussions[indexPath.section][indexPath.row]
            cell.index = indexPath.row
            cell.section = indexPath.section
            cell.delegate = self
            
            if preparedDiscussions[indexPath.section][indexPath.row].author == Settings.userId() ?? "" {
                cell.setupRight()
            } else {
                cell.setupLeft()
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DiscussionVideoCell.self), for: indexPath) as? DiscussionVideoCell else { return UITableViewCell() }
            cell.discussion = preparedDiscussions[indexPath.section][indexPath.row]
            cell.index = indexPath.row
            cell.section = indexPath.section
            cell.delegate = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

enum DiscussionObjectType {
    case Text
    case Video
    case Image
}

struct DiscussionObject {
    
    var type: DiscussionObjectType
    var value: String
    var author: String
    
}

class DiscussionTextCell: UITableViewCell {
    
    var index: Int?
    
    var discussion: DiscussionObject? {
        didSet {
            guard let discussion = discussion else { return }
            txtLabel.text = discussion.value
        }
    }
    

    var txtLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    var dateLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        return label
    }()
    
    var userLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        return label
    }()
    
    var container: UIView = {
       var view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 15
        return view
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        container.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        txtLabel.textColor = .black
        
        container.removeFromSuperview()
        txtLabel.removeFromSuperview()
        dateLabel.removeFromSuperview()
        userLabel.removeFromSuperview()
    }
    
    func setupRight() {
        selectionStyle = .none
        
        addSubview(container)
        container.addSubview(txtLabel)
        addSubview(dateLabel)
        addSubview(userLabel)

        
        container.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-30)
            make.top.equalTo(self.userLabel.snp.bottom).offset(5)
            make.width.lessThanOrEqualTo(250)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        })
        
        txtLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.container.snp.left).offset(7)
            make.right.equalTo(self.container.snp.right).offset(-7)
            make.top.equalTo(self.container.snp.top).offset(7)
            make.bottom.equalTo(self.container.snp.bottom).offset(-7)
        })
        
        dateLabel.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-30)
            make.bottom.equalTo(self.snp.bottom).offset(0)
        })
        
        userLabel.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-30)
            make.top.equalTo(self.snp.top).offset(30)
        })
    
        container.backgroundColor = UIColor.blue
        txtLabel.textColor = .white
    }
    
    func setupLeft() {
        
        selectionStyle = .none
        
        addSubview(container)
        container.addSubview(txtLabel)
        addSubview(dateLabel)
        addSubview(userLabel)

        
        container.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(30)
            make.top.equalTo(self.userLabel.snp.bottom).offset(5)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
            make.width.lessThanOrEqualTo(250)
        })
        
        txtLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.container.snp.left).offset(7)
            make.right.equalTo(self.container.snp.right).offset(-7)
            make.top.equalTo(self.container.snp.top).offset(7)
            make.bottom.equalTo(self.container.snp.bottom).offset(-7)
        })
        
        dateLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(30)
            make.bottom.equalTo(self.snp.bottom).offset(0)
        })
        
        userLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(30)
            make.top.equalTo(self.snp.top).offset(30)
        })
    }
}

protocol DiscussionImageCellDelegate: class {
    func discussionImageCellTapped(url: String)
}

class DiscussionImageCell: UITableViewCell {
    
    var index: Int?
    var section: Int?
    
    weak var delegate: DiscussionImageCellDelegate?
    
    var discussion: DiscussionObject? {
        didSet {
            guard let discussion = discussion else { return }
            img.sd_setImage(with: URL(string: APIMode.Backend + discussion.value), completed: nil)
        }
    }
    
    var dateLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        return label
    }()
    
    var userLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        return label
    }()
    
    func setupLeft() {
        selectionStyle = .none
        
        addSubview(container)
        container.addSubview(img)
        addSubview(dateLabel)
        addSubview(userLabel)

        
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped)))
        
        container.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(30)
            make.top.equalTo(self.userLabel.snp.bottom).offset(5)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
            make.width.equalTo(100)
        })
        
        img.snp.makeConstraints({ make in
            make.left.equalTo(self.container.snp.left).offset(0)
            make.top.equalTo(self.container.snp.top).offset(0)
            make.bottom.equalTo(self.container.snp.bottom).offset(0)
            make.right.equalTo(self.container.snp.right).offset(0)
            make.width.equalTo(100)
            make.height.equalTo(50)
        })
        
        dateLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(30)
            make.bottom.equalTo(self.snp.bottom).offset(0)
        })
        
        userLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(30)
            make.top.equalTo(self.snp.top).offset(30)
        })
    }
    
    func setupRight() {
        selectionStyle = .none
        
        addSubview(container)
        container.addSubview(img)
        addSubview(dateLabel)
        addSubview(userLabel)
        
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped)))
        
        container.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-30)
            make.top.equalTo(self.userLabel.snp.bottom).offset(5)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
            make.width.equalTo(100)
        })
        
        img.snp.makeConstraints({ make in
            make.left.equalTo(self.container.snp.left).offset(0)
            make.top.equalTo(self.container.snp.top).offset(0)
            make.bottom.equalTo(self.container.snp.bottom).offset(0)
            make.right.equalTo(self.container.snp.right).offset(0)
            make.width.equalTo(100)
            make.height.equalTo(50)
        })
        
        dateLabel.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-30)
            make.bottom.equalTo(self.snp.bottom).offset(0)
        })
        
        userLabel.snp.makeConstraints({ make in
            make.right.equalTo(self.snp.right).offset(-30)
            make.top.equalTo(self.snp.top).offset(30)
        })
    }
    
    var img: UIImageView = {
        var view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var container: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        discussion = nil
        container.snp.removeConstraints()
        img.snp.removeConstraints()
        dateLabel.removeFromSuperview()
        userLabel.removeFromSuperview()

    }
    
    @objc func imgTapped() {
        guard let discussion = discussion else { return }
        delegate?.discussionImageCellTapped(url: discussion.value)
    }
    
}

protocol DiscussionVideoCellDelegate: class {
    func discussionVideoCellTapped(url: String)
}

class DiscussionVideoCell: UITableViewCell {
    
    var index: Int?
    var section: Int?
    
    weak var delegate: DiscussionVideoCellDelegate?
    
    var discussion: DiscussionObject? {
        didSet {
            guard let discussion = discussion else { return }
            img.image = UIImage(named: "play_video")
            self.author = discussion.author
        }
    }
    
    var dateLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        return label
    }()
    
    var userLabel: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.italicSystemFont(ofSize: 13)
        return label
    }()
    
    var author: String? {
            didSet {
                guard let author = author else { return }
                if let id = Settings.userId() {
                    if id == author {
                        container.snp.remakeConstraints({ make in
                            make.right.equalTo(self.snp.right).offset(-30)
                            make.top.equalTo(self.userLabel.snp.top).offset(1)
                            make.bottom.equalTo(self.snp.bottom).offset(-20)
                        })
                        container.backgroundColor = UIColor.blue
                        
                        dateLabel.snp.remakeConstraints({ make in
                            make.right.equalTo(self.snp.right).offset(-30)
                            make.bottom.equalTo(self.snp.bottom).offset(0)
                        })
                        
                        userLabel.snp.makeConstraints({ make in
                            make.right.equalTo(self.snp.right).offset(-30)
                            make.top.equalTo(self.snp.top).offset(30)
                        })
                    }
                }
            }
    }
    
    
    var img: UIImageView = {
        var view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var container: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupViews()
        author = nil
    }
    
    @objc func imgTapped() {
        guard let discussion = discussion else { return }
        delegate?.discussionVideoCellTapped(url: discussion.value)
    }
    
    func setupViews() {
        
        selectionStyle = .none
        
        addSubview(container)
        container.addSubview(img)
        addSubview(userLabel)
        
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTapped)))
        
        container.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(5)
            make.top.equalTo(self.userLabel.snp.bottom).offset(2)
            make.bottom.equalTo(self.snp.bottom).offset(-20)
        })
        
        img.snp.makeConstraints({ make in
            make.left.equalTo(self.container.snp.left).offset(0)
            make.top.equalTo(self.container.snp.top).offset(0)
            make.bottom.equalTo(self.container.snp.bottom).offset(0)
            make.right.equalTo(self.container.snp.right).offset(0)
            make.width.equalTo(100)
            make.height.equalTo(50)
        })
        
        dateLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(5)
            make.bottom.equalTo(self.snp.bottom).offset(0)
        })
        
        userLabel.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left).offset(30)
            make.top.equalTo(self.snp.top).offset(30)
        })
    }
}
