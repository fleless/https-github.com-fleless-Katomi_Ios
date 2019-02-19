//
//  CalendarTableViewCell.swift
//  kat
//
//  Created by amine on 10/18/18.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var motifLbl: UILabel!
    @IBOutlet weak var patientName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
