//
//  AccessoryView.swift
//  swift2048_THIRD
//
//  Created by jansti on 16/9/26.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

protocol ScoreViewProtocol {
    func scoreChanged(newScore s: Int)
}

class ScoreView: UIView, ScoreViewProtocol {
    var score: Int = 0 {
        didSet {
            label.text = "SCORE: \(score)"
        }
    }
    
    let defaultFrame = CGRect.init(x: 0, y: 0, width: 140, height: 40)
    var label: UILabel
    
    init(frame: CGRect) {
        <#code#>
    }
    
}


































