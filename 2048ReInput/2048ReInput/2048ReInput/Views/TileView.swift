//
//  TileView.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit


class TileView: UIView{
    
    var value: Int = 0{
        didSet{ // 每次改变value,需要改变背景色,数字颜色还有显示的数字text.颜色的信息,由代理那边获取.
            backgroundColor = delegate.tileColor(value)
            numberLabel.textColor = delegate.numberColor(value)
            numberLabel.text = "\(value)"
        }
    }
    
    unowned let delegate: AppearanceProviderProtocol // 专门提供颜色信息的delegate
    let numberLabel: UILabel
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    // position是在boardView里面,更具tile在存放数据的数组的序列号,和boardView的宽高计算出来的,width也是一样的.delegate是在tileView的父视图,boardView中保存的.
    init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d:AppearanceProviderProtocol){
        delegate = d
        numberLabel = UILabel(frame: CGRectMake(0, 0, width, width))
        numberLabel.textAlignment = NSTextAlignment.Center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = delegate.fontForNumbers()
        
        super.init(frame: CGRectMake(position.x, position.y, width, width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        
        self.value = value
        backgroundColor = delegate.tileColor(value)
        numberLabel.textColor = delegate.numberColor(value)
        numberLabel.text = "\(value)"
    }
}






































