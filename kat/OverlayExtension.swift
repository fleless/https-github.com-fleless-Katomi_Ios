//
//  OverlayExtension.swift
//  kat
//
//  Created by amine on 13/09/2018.
//  Copyright © 2018 factor619. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    
    func OverlayView() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
}
