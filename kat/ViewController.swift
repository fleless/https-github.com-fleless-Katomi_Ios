//
//  ViewController.swift
//  kat
//
//  Created by fahmex on 28/08/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var copyright: UILabel!
    @IBOutlet weak var container: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.copyright.isHidden = true
        self.container.alpha = 0.0
        UIView.animate(withDuration: 2, animations: {
            self.logo.frame.origin.y = 100
            sleep(1)
            self.container.alpha = 1.0
        }, completion: {(finished:Bool) in
        })
    }
    
}

