//
//  GameModel.swift
//  2048Self
//
//  Created by jansti on 16/9/20.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

protocol GameModelProtocol : class {
    func scoreChanged(score: Int)
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    func insertTile(location: (Int, Int), value: Int)
}


class GameModel: NSObject{
    
    let dimension: Int
    let threshold: Int
    
    unowned let delegate: GameModelProtocol
    var gameboard: SquareGameboard<TileObject>
    
    var queue: [MoveCommand]
    var timer: NSTimer
    
    let maxCommands = 100
    let queueDelay = 0.3
    
    var score: Int = 0{
        didSet {
            delegate.scoreChanged(score)
        }
    }
    
    init(dimension d: Int, threshold t: Int, delegate: GameModelProtocol) {
        dimension = d
        threshold = t
        self.delegate = delegate
        queue = [MoveCommand]()
        timer = NSTimer()
        gameboard = SquareGameboard(dimension: d, initialValue: .Empty)
        super.init()
    }
    
    func reset(){
        score = 0
        gameboard.setAll(.Empty)
        queue.removeAll(keepCapacity: true)
        timer.invalidate()
    }
    
    
    func queueMove(direction: MoveDirection, completion: (Bool) -> Void){
        guard queue.count <= maxCommands else {
            return
        }
        
        queue.append(MoveCommand(direction: direction, completion: completion))
        if !timer.valid{
            timeFired(timer)
        }
    }
    
    
    func timeFired(_ :NSTimer){
        if queue.count == 0{
            return
        }
        
        var changed = false
        while queue.count > 0 {
            let command = queue[0]
            queue.removeAtIndex(0)
            changed = performMove(command.direction)
            command.completion(changed)
            if changed {
                break
            }
        }
        
        if changed {
            timer = NSTimer.scheduledTimerWithTimeInterval(queueDelay,
                                                           target: self,
                                                           selector:
                Selector("timerFired:"),
                                                           userInfo: nil,
                                                           repeats: false)
        }
}
    
    
    
    // Perform all calculations and update state for a single move.
    func performMove(direction: MoveDirection) -> Bool{
        
        let coordinateGenerator: (Int) -> [(Int, Int)] = { iteration in
            var buffer = Array<(Int,Int)>(count: self.dimension, repeatedValue: (0, 0))
            for i in 0..<self.dimension{
                switch direction {
                case .Up: buffer[i] = (i, iteration)
                case .Down: buffer[i] = (self.dimension - i - 1, iteration)
                case .Left: buffer[i] = (iteration, i)
                case .Right: buffer[i] = (iteration, self.dimension - i - 1)
                }
            }
                
            return buffer
        }
        
        var atLeastOneMove = false
        
        for i in 0..<dimension{
            let coords = coordinateGenerator(i)
            
            let tiles = coords.map({ (c: (Int, Int)) -> TileObject in
                let (x, y) = c
                return self.gameboard[x, y]
            })
            
            
        }
        
        
        
        return atLeastOneMove
    }
    
    
    
    
    
    
    
    
}























