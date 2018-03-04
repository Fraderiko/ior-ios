//
//  CollectionViewCell.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionViewCellDelegate: class {
    func collectionViewItemDidTapped(item: Int, section: Int?, index: Int, type: CollectionViewCellType)
}

enum CollectionViewCellType {
    case Video
    case Image
}

class CollectionViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    weak var delegate: CollectionViewCellDelegate?
    
    var urls: [String] = []
    
    var type: CollectionViewCellType?
    var index: Int?
    var section: Int?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 160, height: 100)
        layout.minimumInteritemSpacing = 30
        var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewImageCell.self, forCellWithReuseIdentifier: NSStringFromClass(CollectionViewImageCell.self))
        collectionView.register(CollectionViewVideoCell.self, forCellWithReuseIdentifier: NSStringFromClass(CollectionViewVideoCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        collectionView.reloadData()
    }
    
    func setupViews() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints({ make in
            make.left.equalTo(self.snp.left)
            make.right.equalTo(self.snp.right)
            make.top.equalTo(self.snp.top).offset(2)
            make.height.equalTo(96)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let type = type else { return UICollectionViewCell()  }
        if type == .Image {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CollectionViewImageCell.self), for: indexPath) as? CollectionViewImageCell else { return UICollectionViewCell() }
            cell.url = urls[indexPath.item]
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CollectionViewVideoCell.self), for: indexPath) as? CollectionViewVideoCell else { return UICollectionViewCell() }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let type = type, let index = index else { return }
        delegate?.collectionViewItemDidTapped(item: indexPath.item, section: section, index: index, type: type)
    }
}
