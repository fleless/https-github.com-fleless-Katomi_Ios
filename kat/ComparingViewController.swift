//
//  ComparingViewController.swift
//  kat
//
//  Created by amine on 9/19/18.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit

class ComparingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var selectedImages: [UIImage]!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let img:UIImageView = cell.viewWithTag(69) as! UIImageView
        
        img.image = self.selectedImages[indexPath.row]
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        img.layer.borderWidth = 2
        img.layer.borderColor = UIColor(red:10/255, green:15/255, blue:59/255, alpha: 1).cgColor
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.size.width-70.5) //some width
        let height = width //ratio
        return CGSize(width: width, height: height)
    }
}
