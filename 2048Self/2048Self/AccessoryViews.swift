//
//  AccessoryViews.swift
//  2048Self
//
//  Created by jansti on 16/9/20.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

protocol ScoreViewProtocol {
    func scoreChanged(newScore s: Int)
}


// a view display the socre

class ScoreView: UIView, ScoreViewProtocol {
    
    var score: Int = 0{
        didSet {
            label.text = "Score: \(score)"
        }
    }
    
    let defaultFrame = CGRectMake(0, 0, 140, 40)
    var label: UILabel
    
    init(backgroundColor bgColor: UIColor, textColor tcolor: UIColor, font: UIFont, radius r: CGFloat){
        label = UILabel(frame: self.defaultFrame)
        label.textAlignment = .Center
        super.init(frame: defaultFrame)
        backgroundColor = bgColor
        label.textColor = tcolor
        label.font = font
        layer.cornerRadius = r
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func scoreChanged(newScore s: Int) {
        score = s
    }
    
}











































