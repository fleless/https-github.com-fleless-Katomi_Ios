//
//  EditImageViewController.swift
//  kat
//
//  Created by fahmex on 10/09/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit
import AKImageCropperView

class EditImageViewController: UIViewController {

    @IBOutlet weak var cropper: AKImageCropperOverlayView!
    override func viewDidLoad() {
        super.viewDidLoad()
        cropper.image = #imageLiteral(resourceName: "person")
    }
    func init(image: UIImage?)
    
}
