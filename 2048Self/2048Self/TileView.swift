//
//  TileView.swift
//  2048Self
//
//  Created by jansti on 16/9/20.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit



class TileView: UIView {
    
    var value: Int = 0{
        didSet{
            backgroundColor = delegate.tileColor(value)
            numberLabel.textColor = delegate.numberColor(value)
            numberLabel.text = "\(value)"
        }
    }
    
    unowned let delegate: AppearanceProviderProtocol
    let numberLabel: UILabel
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: AppearanceProviderProtocol){
        
        delegate = d
        numberLabel = UILabel.init(frame: CGRectMake(0, 0, width, width))
        numberLabel.textAlignment = .Center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = delegate.fontForNumbers()
        
        super.init(frame: CGRectMake(0, 0, width, width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        
        self.value = value
        backgroundColor = delegate.tileColor(value)
        numberLabel.textColor = delegate.numberColor(value)
        numberLabel.text = "\(value)"
    }
}




































