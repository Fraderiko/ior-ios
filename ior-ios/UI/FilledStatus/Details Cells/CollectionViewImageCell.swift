//
//  CollectionViewImageCell.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewImageCell: UICollectionViewCell {
    
    var url: String? {
        didSet {
            guard let url = url else { return }
            let urlPath = URL(string: APIMode.Backend + url)
            self.img.sd_addActivityIndicator()
            self.img.sd_setImage(with: urlPath, completed: nil)
        }
    }
    
    lazy var img: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(img)
        img.snp.makeConstraints({ make in
            make.edges.equalTo(self)
        })
    }
    
    override func prepareForReuse() {
        
    }
}
