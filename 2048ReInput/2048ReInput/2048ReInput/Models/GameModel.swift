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
    func scoreChanged(_ score: Int)
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    func insertTile(_ location: (Int, Int), value: Int)
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
        queue = [MoveCommand]()
        timer = Timer()
        gameboard = SquareGameboard(dimension: d, initialValue: .empty)
        super.init()
    }

    let maxCommands = 100
    let queueDelay = 0.3
    
    var queue: [MoveCommand]
    var timer: Timer
    
    func queueMove(_ direction: MoveDirection, completion: @escaping (Bool) -> ()) {
        guard queue.count <= maxCommands else{
            return
        }
        queue.append(MoveCommand(direction: direction, completion: completion))
        
        if !timer.isValid{
            timerFired(timer)
        }
    }
    
    func timerFired(_: Timer) {
        if queue.count == 0{
            return
        }
        
        var changed = false
        while queue.count >= 0 {
            let command = queue[0]
            queue.remove(at: 0)
            changed = performMove(command.direction)
            command.completion(changed)
            if changed{
                break
            }
        }
        if changed {
            timer = Timer.scheduledTimer(timeInterval: queueDelay,
                                                           target: self,
                                                           selector:
                #selector(GameModel.timerFired(_:)),
                                                           userInfo: nil,
                                                           repeats: false)
        }
    }
    
    
    // Perform all calculations and update state for a single move.
    
    func performMove(_ direction: MoveDirection) -> Bool{
        
        let coordinateGenerator: (Int) -> [(Int, Int)] = { (iteration: Int) in
            var buffer = Array<(Int, Int)>(repeating: (0, 0), count: self.dimension)
            for i in 0..<self.dimension{
                switch direction {
                case .up: buffer[i] = (i, iteration)
                case .down: buffer[i] = (self.dimension - i - 1, iteration)
                case .left: buffer[i] = (iteration, i)
                case .right: buffer[i] = (iteration, self.dimension - i - 1)
                }
            }
            return buffer // buffer ,如果是up,那么就是0,0 1,0 2,0 3,0 这个数组,是和up方向向顺的,从上到下的一个位置数组.
        }
        
        let atLeastOneMove = false
        for i in 0..<dimension{
            
            let coords = coordinateGenerator(i)
            let tiles = coords.map({ (c) -> TileObject in
                let (x, y) = c
                return self.gameboard[x, y]
            }) //buffer里面的是位置数组,这里将它转换成tileObjct数组了.就是在这个数组的位置上,是不是nil,不是的话,value是多少
            
            
            
            let orders = merge(tiles)
            
            
        }
        return atLeastOneMove
    }
    
    
    
    
    
    
    //------------------------------------------------------------------------------------------------------------------//
    
    /// When computing the effects of a move upon a row of tiles, calculate and return a list of ActionTokens
    /// corresponding to any moves necessary to remove interstital space. For example, |[2][ ][ ][4]| will become
    /// |[2][4]|.
    
    
    //: # condense 浓缩,这一步,是将空白格子消除掉.ActionToken在这一步只会增加两个选项,一个是不动,一个是移动,都包含了原来位置和value值.在经过这一步后,这个函数认为,会有tokenBuffer个值存在.这个个数,是这一行,或者这一列不为空的值的个数.这,是还没有合并的时候的值的个数,下一步就是合并了.
    func condense(_ group: [TileObject]) -> [ActionToken] {
        
        var tokenBuffer = [ActionToken]()
        for (idx, tile) in group.enumerated(){
            switch tile{
            case let .tile(value) where tokenBuffer.count == idx:
                // 这里为什么要这么判断呢.tokenBuffer是存放有值的2048游戏块的一个数组.如果group这个数组里,每一个对象都有值,那么tokenbuffer的数量,就应该和idx相等.只要中间出现了一个nil值,那么在这个nil对象之后的对象,都应该移动.注意,这一步没有考虑合并的情况,合并的情况会在下一步考虑.
                tokenBuffer.append(ActionToken.noAction(source: idx, value: value))
            case let .tile(value):
                tokenBuffer.append(ActionToken.move(source: idx, value: value))
            default:
                break //tokenBuffer只存放有值的情况
            }
        }
        return tokenBuffer
    }
    
    class func quiescentTileStillQuiescent(_ inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        // Return whether or not a 'NoAction' token still represents an unmoved tile
        return (inputPosition == outputLength) && (inputPosition == originalPosition )
    }
    
    /// When computing the effects of a move upon a row of tiles, calculate and return an updated list of ActionTokens
    /// corresponding to any merges that should take place. This method collapses adjacent tiles of equal value, but each
    /// tile can take part in at most one collapse per move. For example, |[1][1][1][2][2]| will become |[2][1][4]|.
    
    // 在经过上一次的过滤掉nil之后,这一步就是进行了合并的操作了.
    // 首先,合并会出现在什么情况下呢,就是第一个值,和它后面的游戏块的值是一样的情况.
    func collapse(_ group: [ActionToken]) -> [ActionToken] {
        
        var tokenBuffer = [ActionToken]()
        var skipNext = false
        for (idx, token) in group.enumerated(){
            
            if skipNext{
                // 之前的操作是一个merge操作,已经操作了这个游戏块了,应该跳过
                skipNext = false
                continue
            }
            
            switch token {
            case .singleCombine:
                assert(false, "Cannot have single combine token in input")
            case .doubleCombine:
                assert(false, "Cannot have double combine token in input")
            default:
                break
                
                
                
            }
        }
       
        
        
        return tokenBuffer
}
    
    /// When computing the effects of a move upon a row of tiles, take a list of ActionTokens prepared by the condense()
    /// and convert() methods and convert them into MoveOrders that can be fed back to the delegate.
    func convert(_ group: [ActionToken]) -> [MoveOrder] {
        var moveBuffer = [MoveOrder]()
        for (idx, t) in group.enumerated() {
            switch t {
            case let .move(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: false))
            case let .singleCombine(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: true))
            case let .doubleCombine(s1, s2, v):
                moveBuffer.append(MoveOrder.doubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
            default:
                // Don't do anything
                break
            }
        }
        return moveBuffer
    }
    
    /// Given an array of TileObjects, perform a collapse and create an array of move orders.
    func merge(_ group: [TileObject]) -> [MoveOrder] {
        // Calculation takes place in three steps:
        // 1. Calculate the moves necessary to produce the same tiles, but without any interstital space.
        // 2. Take the above, and calculate the moves necessary to collapse adjacent tiles of equal value.
        // 3. Take the above, and convert into MoveOrders that provide all necessary information to the delegate.
        return convert(collapse(condense(group)))
    }
    
    
}
















































