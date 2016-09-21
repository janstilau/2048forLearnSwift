//
//  AccessoryViews.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit


// 这里专门是写了一个protocol,而在GameVC的属性里面,后面标写的类型也是ScoreViewProtocol,如果在OC里面,那么这可能是一个id<ScoreViewProtocol> 类型的一个属性,而在Swift里面,直接可以把ScoreViewProtocol写到类型的位置,表明了这个属性是这个类型.
protocol ScoreViewProtocol {
    func scoreChanged(newScore s: Int)
}

// 分数view.初始化加label,didSet Score属性改变label的text外观


class ScoreView: UIView, ScoreViewProtocol {
    
    let defaultFrame = CGRectMake(0, 0, 140, 140) // let 可以用作常量来表示,之前在OC里面要表示常量,只能用static const,或者设置属性,在初始化的时候,预先在初始化的函数里面填写预定义的值.由于在Swift里面,可以在定义的时候进行赋值,并且let表示const的含义,所以可以把let属性当做const常量使用.
    
    var label: UILabel
    
    var score: Int = 0 {
        didSet{
            label.text = "Score: \(score)"
        }
    }
    
    init(backgroundColor bgcolor: UIColor, textColor tcolor: UIColor, font: UIFont, radius r: CGFloat){
//        layer.cornerRadius = r
//        layer = CALayer.init()
        label = UILabel(frame: defaultFrame) // 首先初始化自己类引入的属性
        label.textAlignment = NSTextAlignment.Center
        super.init(frame: defaultFrame) //然后调用父类的desinatedInit方法
        backgroundColor = bgcolor // 然后,改变父类的属性
        label.textColor = tcolor
        layer.cornerRadius = r
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scoreChanged(newScore s: Int)  {
        score = s
    }
    
}


































