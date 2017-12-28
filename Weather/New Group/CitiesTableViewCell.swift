//
//  CitiesTableViewCell.swift
//  Weather
//
//  Created by Ritz on 2017-11-11.
//  Copyright © 2017 Seneca college. All rights reserved.
//

import UIKit

class CitiesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

