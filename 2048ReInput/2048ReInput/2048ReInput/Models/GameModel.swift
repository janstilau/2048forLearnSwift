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
    
    class func quiescentTileStillQuiescent(_ inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        // Return whether or not a 'NoAction' token still represents an unmoved tile
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
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
        
        var atLeastOneMove = false
        for i in 0..<dimension{
            
            let coords = coordinateGenerator(i)
            let tiles = coords.map({ (c) -> TileObject in
                let (x, y) = c
                return self.gameboard[x, y]
            }) //coords里面的是位置数组,这里将它转换成tileObjct数组了.就是在这个数组的位置上,是不是nil,不是的话,value是多少
            
            
            
            let orders = merge(tiles)
            atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
            
            for object in orders {
                
                switch object{
                case let MoveOrder.singleMoveOrder(source: s, destination: d, value: v, wasMerge: wasMerge):
                    
                    let (sx, sy) = coords[s]
                    let (dx, dy) = coords[d]
                    if wasMerge {
                        score += v
                    }
                    
                    gameboard[sx, sy] = TileObject.empty
                    gameboard[dx, dy] = TileObject.tile(v)
                    delegate.moveOneTile(coords[s], to: coords[d], value: v)
                    // 在改变完数据之后,在进行图像的变化.delegate是控制器,由控制器在调用boardView的变化.
                case let MoveOrder.doubleMoveOrder(s1, s2, d, v):
                    // Perform a simultaneous two-tile move
                    let (s1x, s1y) = coords[s1]
                    let (s2x, s2y) = coords[s2]
                    let (dx, dy) = coords[d]
                    score += v
                    gameboard[s1x, s1y] = TileObject.empty
                    gameboard[s2x, s2y] = TileObject.empty
                    gameboard[dx, dy] = TileObject.tile(v)
                    delegate.moveTwoTiles((coords[s1], coords[s2]), to: coords[d], value: v)
                }
            }
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
            case let .noAction(s, v):
                where (idx < group.count - 1 && v == group[idx+1].getValue()
                && GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s)) :
                // 这里为什么要这么判断,首先前面两项很容易分辨,如果不是最后一项,并且它的值和后一项的值相等那么就应该合并.但是这种情况会有两种的,一种是,前一个游戏格不动,后一个游戏格撞过来,一种是两个游戏格子一起动,最后合并.最后的一项关系运算就是判别不动的这种情况.如果,是这种情况.那么这个格子的idx应该就是tokenBuffer的count,后面又和原始的位置比较下,应该是不必要的.
                let next = group[idx + 1]
                let nv = v + group[idx+1].getValue()
                skipNext = true // 合并的情况,下一项是要过滤的
                tokenBuffer.append(ActionToken.singleCombine(source: next.getSource(), value: nv))
                // 这里虽然是判断的前一项,但是添加进去的, 是按照后一项向前移动定义的.下一项会被skip掉,所以没有错误.
            case let t where( idx < group.count - 1 && t.getValue() == group[idx+1].getValue()):
                //这里就是剩下的合并的情况了.由于swift的switch是从上到下匹配的,所以这里用一般的合并的情况判断,就应该是两个游戏块同时移动的结果.
                let next = group[idx+1]
                let nv = t.getValue() + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.doubleCombine(source: t.getSource(), second: next.getSource(), value: nv))
            case let .noAction(s, v) where !GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s):
                // 这里noAction为什么会被当成了move了.对于4 2211这种情况,在第一步的condense里面,是消除空格,那么到这一步的时候,会保留5个值,no,no,no,no,move,但是在这一步的时候,是合并了.11一定会合并成2,idx和tokenbuffer.count就可以判断出,前面合并了,no应该变成move
                tokenBuffer.append(ActionToken.move(source: s, value: v))
            case let .noAction(s, v):
                //剩下的noAction,就该是真的不动的
                tokenBuffer.append(ActionToken.noAction(source: s, value: v))
            case let .move(s, v):
                tokenBuffer.append(ActionToken.move(source: s, value: v))
                //这里的move,应该是合并的结果剩下的move,2 2 2,这里后面的2在第一步都是move,但是第2个2的move因为merge被skip掉了.
            default:
                break
            }
        }
        
        
        // 经过上面的判断之后更改数组,得到的是消除了空格和合并后的结果,但是,到底游戏块应该在什么位置呢.其实,这个数组里面的,留下来的就是滑动方向上的有值的游戏快的顺序了,在下一步就该做最后的整理了.
        return tokenBuffer
}
    
    /// When computing the effects of a move upon a row of tiles, take a list of ActionTokens prepared by the condense()
    /// and convert() methods and convert them into MoveOrders that can be fed back to the delegate.
    func convert(_ group: [ActionToken]) -> [MoveOrder] {
       var moveBuffer = [MoveOrder]()
        // 其实,group里面的idx就是destination的数值,因为2048这个游戏,滑动一次之后,这个方向的游戏块都是紧挨着的,然后出现新的游戏块才会出现空隙
        for (idx, t) in group.enumerated(){
            switch t {
            case let .move(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: false))
            case let .singleCombine(s, v):
                moveBuffer.append(MoveOrder.singleMoveOrder(source: s, destination: idx, value: v, wasMerge: true))
            case let .doubleCombine(s1, s2, v):
                moveBuffer.append(MoveOrder.doubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
            default: break
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
















































