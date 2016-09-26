//
//  TileView.swift
//  swift2048_THIRD
//
//  Created by jansti on 16/9/26.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

class TileView: UIView {
    var value: Int = 0 { // 如果value没有默认值的话,那么在init的时候,superinit之前必须给value赋值
        didSet{
            backgroundColor = delegate.tileColor(value)
            numberLabel.textColor = delegate.numberColor(value)
            numberLabel.text = "\(value)"
        }
    }
    
    unowned let delegate: AppearanceProviderProtocol
    let numberLabel: UILabel
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(position: CGPoint, width: CGFloat,value: Int, radius: CGFloat, delegate d:AppearanceProviderProtocol) {
        delegate = d
        numberLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: width, height: width))
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = delegate.fontForNumbers()
        
        super.init(frame: CGRect.init(x: position.x, y: position.y, width: width, height: width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        
        self.value = value
        backgroundColor = delegate.tileColor(value)
        numberLabel.textColor = delegate.numberColor(value)
        numberLabel.text = "\(value)"
    }
}

























