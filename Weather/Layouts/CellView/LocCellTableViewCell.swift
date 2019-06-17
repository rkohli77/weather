//
//  LocCellTableViewCell.swift
//  Weather
//
//  Created by Ritz on 2017-12-28.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit

class LocCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tempLbl: UILabel!
    
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var cityLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
