//
//  UIButtonCustom.swift
//  tounsyleltounsyIOS
//
//  Created by fahmex on 15/11/2017.
//  Copyright © 2017 fahmex. All rights reserved.
//

import UIKit
@IBDesignable
class CustomUIbutton: UIButton {
    
    @IBInspectable var fillColor: UIColor = UIColor.blue
    @IBInspectable var cornerRadius: CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = fillColor.cgColor
    }
    
}
