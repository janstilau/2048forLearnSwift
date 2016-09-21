//
//  GameModel.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

// model和gamevc交互的一个protocol
protocol GameModelProtocol: class {
    func scoreChanged(score: Int)
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    func insertTile(location: (Int, Int), value: Int)
}

class GameModel: NSObject{
    
    let dimension: Int
    let threshold: Int
    
    var gameboard: SquareGameboard<TileObject>
    unowned let delegate: GameModelProtocol
    
    var score: Int = 0{
        didSet{
            delegate.scoreChanged(score)
        }
    }
    
    init(dimension d: Int, threshold t: Int, delegate: GameModelProtocol) {
        dimension = d
        threshold = t
        self.delegate = delegate
//        queue = [MoveCommand]()
//        timer = NSTimer()
        gameboard = SquareGameboard(dimension: d, initialValue: .Empty)
        super.init()
    }

    
    func queueMove(direction: MoveDirection, completion: (Bool) -> ()) {
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
















































