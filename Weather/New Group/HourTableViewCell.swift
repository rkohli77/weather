//
//  HourTableViewCell.swift
//  Weather
//
//  Created by Ritz on 2017-12-30.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit

class HourTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func layoutSubviews() {
       collectionView.backgroundColor = UIColor.clear
        collectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
