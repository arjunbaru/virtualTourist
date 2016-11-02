//
//  photoCollectionViewCell.swift
//  virtualTourist
//
//  Created by Arjun Baru on 24/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell : UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        if imageView.image == nil {
            activityIndicator.startAnimating()
        }
    }
    
}
