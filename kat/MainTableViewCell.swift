//
//  MainTableViewCell.swift
//  TableViewCustomCell
//
//  Created by Grimg on 9/11/18.
//  Copyright © 2018 Grimg. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var motifLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension MainTableViewCell
{
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDelegate & UICollectionViewDataSource> (_ dataSourceDelegate: D, forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        
        collectionView.reloadData()
    }
}
