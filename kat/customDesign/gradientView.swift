//
//  GradientView.swift
//  tounsyleltounsyIOS
//
//  Created by fahmi Barguellil on 15/11/2017.
//  Copyright © 2017 fahmex. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var endColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var centerColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get{
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [ startColor.cgColor,endColor.cgColor ]
        layer.locations = [ 0.0,1.1 ]
    }
    
    
}
