//
//  CollectionViewVideoCell.swift
//  ior-ios
//
//  Created by me on 20/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewVideoCell: CollectionViewImageCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        img.image = UIImage(named: "play_video")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        img.image = UIImage()
    }
}
