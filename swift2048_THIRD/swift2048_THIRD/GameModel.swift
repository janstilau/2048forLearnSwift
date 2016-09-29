
//
//  GameModel.swift
//  swift2048_THIRD
//
//  Created by jansti on 16/9/28.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

// GameModelProtocol这个协议,是NumberTileGame实现的,游戏的主控制类.这个类中有一个模型,还有一个boardView,模型处理数据,然后delegate给game类,然后game类调用视图类的移动方法,来实现游戏的进行.
protocol GameModelProtocol: class {
    
    func scoreChanged(_ score: Int)
    func moveOneTile(_ form: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(_ from:((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
    func insertTile(_ location: (Int, Int), value: Int)
}

class GameModel: NSObject{
    
    let dimension: Int
    let threshold: Int
    
    var score: Int = 0{
        didSet {
            delegate.scoreChanged(score)
        }
    }
    
    var gameboard: SquareGameBoard<TileObject>
    unowned let delegate: GameModelProtocol
    
    var queue: [MoveCommand]
    var timer: Timer
    
    let maxCommands = 100
    let queueDelay = 0.3
    
    init(dimension d: Int, threshold t: Int, delegate: GameModelProtocol){
        dimension = d
        threshold = t
        self.delegate = delegate
        queue = [MoveCommand]()
        timer = Timer()
        gameboard = SquareGameBoard.init(dimension: d, initialValue: .empty)
        super.init()
    }
    
    func reset(){
        score = 0
        gameboard.setAll(.empty)
        queue.removeAll(keepingCapacity: true)
        timer.invalidate()
    }
    
    func queueMove(_ direction: MoveDirection, completion: @escaping (Bool) -> ()){
        
        guard queue.count <= maxCommands else {
            return
        }
        
        queue.append(MoveCommand(direction: direction, completion: completion))// 这个moveCommand仅仅记录了滑动的方向,以及滑动完之后该做的操作,这里就是判断胜利或者失败.
        if !timer.isValid {
            timerFired(timer)
        }
    }
    
    func timerFired(_ :Timer){
        if queue.count == 0{
            return
        }
        
        var changed = false
        while queue.count > 0{
            let command = queue[0]
            queue.remove(at: 0)
            changed = performMove(command.direction)
            command.completion(changed)
            if changed{
                break
            }
        }
        
        // 这里,为什么要在changed里面初始化timer.
        // 其实,在init里面,timer仅仅是初始化了一下,为的是swift的init必须要全部都有默认值这样的规定.但是timer并没有运行.在第一次触动了屏幕的时候,timerFired这个方法被调用了,在处理完上面的循环之后,changed为true.这样timer就会被重新初始化然后加入到运行循环,这样timer就可以开始运行了.
        // 然后我们注意到,这个timer的repeats是false.所以之后运行一次,那么在下一次的运行的时候,首先会检测queue.count,如果里面有值,就代表又有触摸滑动的操作,然后进行合并.
        // 值得注意的是,这一次检测的时候,可能会有很多次的操作.因为上一次的timer的delay时间是0.3秒,在queueMove的时候,仅仅是把所有的操作进行保存了,然后统一在timer到时间的时候处理.所以在屏幕上,理论上会出现,很多操作突然发生,然后在下一次0.3秒的时候,再一次很多操作同时发生.但是为什么在视觉上没有出现这样的情况呢.首先0.3秒很短,在这,gameBoardView的动画是formCurrentState.如果一个游戏块在横滑动的时候,需要向上移动,那么这个游戏块是斜着过去的.在0.08秒的时间内,肉眼还是很难分辨的.
        // 这里,是根据changed来进行timer的赋值.如果有了变化,就用timer检测一下,如果没有变化,这个timer就invalidate了.那么下一次再触摸的时候,这个timer就是!isvalid的了,这样就又进入到timerFired这个函数了.首先处理queue里面的command,然后根据changed的配置timer.
        // timer并不是一个一直检测,轮查的timer,根据changed的值,来进行配置,这样节约性能.
        if changed {
            timer = Timer.scheduledTimer(timeInterval: queueDelay, target: self, selector: #selector(GameModel.timerFired(_:)), userInfo: nil, repeats: false)
        }
    }
    
    func insertTile(_ position: (Int, Int), value: Int){
        let (x, y) = position
        if case .empty = gameboard[x, y]{  // wtf 下面是原始的写法,新语法
            gameboard[x, y] = TileObject.tile(value)
            delegate.insertTile(position, value: value)
        }
    }
    
//    func insertTile(pos: (Int, Int), value: Int) {
//        let (x, y) = pos
//        switch gameboard[x, y] {
//        case .Empty:
//            gameboard[x, y] = TileObject.Tile(value)
//            delegate.insertTile(pos, value: value)
//        case .Tile:
//            break
//        }
//    }
    
    
    func gameboardEmptySpots() -> [(Int, Int)] {
        var buffer: [(Int, Int)] = []
        for i in 0..<dimension {
            for j in 0..<dimension {
                if case .empty = gameboard[i, j]{
                    buffer += [(i, j)]
                }
            }
        }
        
        return buffer
    }
    
    func insertTileAtRandomLocation(_ value: Int){
        let openSpots = gameboardEmptySpots()
        if openSpots.isEmpty {
            return
        }
        
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        let (x, y) = openSpots[idx]
        insertTile((x, y), value: value)
    }
    
    func tileBelowHasSameValue(_ location: (Int,Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard y != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gameboard[x, y+1]{
            return v == value
        }
        return false
    }
    
    func tileToRightHasSameValue(_ location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard x != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gameboard[x+1, y]{
            return v == value
        }
        return false
    }
    
    func userHasLost() -> Bool {
        guard gameboardEmptySpots().isEmpty else {
            return false
        }
        
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gameboard[i, j] {
                case .empty:
                    assert(false, "Gameboard reported isself as full, but we still found an empty tile, and this is a logic erre")
                case let .tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileToRightHasSameValue((i, j), v){
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    func userHasWon() -> (Bool, (Int, Int)?) {
        for i in 0..<dimension{
            for j in 0..<dimension{
                if case let .tile(v) = gameboard[i, j], v > threshold {
                    return (true, (i, j))
                }
            }
        }
        
        return (false ,nil)
    }
    
    
    
    
    func performMove(_ direction: MoveDirection) -> Bool {
        
        let coordinateGenerator: (Int) -> [(Int, Int)] = { (iteration) in
            var buffer = Array<(Int, Int)>.init(repeating: (0, 0), count: self.dimension)
            for i in 0..<self.dimension{
                switch direction{
                case .up: buffer[i] = (i, iteration)
                case .down: buffer[i] = (self.dimension - i - 1, iteration)
                case .left: buffer[i] = (iteration, i)
                case .right: buffer[i] = (iteration, self.dimension - i - 1)
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
            
            let orders = merge(tiles)// merge主要的合并的操作tiles是在某个方向上的,例如,右滑,就是第一行,第二行,在水平方向上的,从右向左的游戏块的数组,然后这个数组在merge里面合并最后返回一个MoveOrder的数组.根据这个数组里面的值进行数值的操作和view的变化.
            atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
            
            for object in orders{
                switch object {
                case let MoveOrder.singleMoveOrder(s, d, v, wasMerge):
                    // Perform a single-tile move
                    let (sx, sy) = coords[s]
                    let (dx, dy) = coords[d]
                    if wasMerge {
                        score += v
                    }
                    gameboard[sx, sy] = TileObject.empty
                    gameboard[dx, dy] = TileObject.tile(v)
                    delegate.moveOneTile(coords[s], to: coords[d], value: v)
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
    
    func condense(_ group: [TileObject]) -> [ActionToken] {
        var tokenBuffer = [ActionToken]()
        for (idx, tile) in group.enumerated() {
            // Go through all the tiles in 'group'. When we see a tile 'out of place', create a corresponding ActionToken.
            switch tile {
            case let .tile(value) where tokenBuffer.count == idx:
                tokenBuffer.append(ActionToken.noAction(source: idx, value: value))
            case let .tile(value):
                tokenBuffer.append(ActionToken.move(source: idx, value: value))
            default:
                break
            }
        }
        return tokenBuffer;
    }
    
    class func quiescentTileStillQuiescent(_ inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        // Return whether or not a 'NoAction' token still represents an unmoved tile
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }
    
    /// When computing the effects of a move upon a row of tiles, calculate and return an updated list of ActionTokens
    /// corresponding to any merges that should take place. This method collapses adjacent tiles of equal value, but each
    /// tile can take part in at most one collapse per move. For example, |[1][1][1][2][2]| will become |[2][1][4]|.
    func collapse(_ group: [ActionToken]) -> [ActionToken] {
        
        
        var tokenBuffer = [ActionToken]()
        var skipNext = false
        for (idx, token) in group.enumerated() {
            if skipNext {
                // Prior iteration handled a merge. So skip this iteration.
                skipNext = false
                continue
            }
            switch token {
            case .singleCombine:
                assert(false, "Cannot have single combine token in input")
            case .doubleCombine:
                assert(false, "Cannot have double combine token in input")
            case let .noAction(s, v)
                where (idx < group.count-1
                    && v == group[idx+1].getValue()
                    && GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s)):
                // This tile hasn't moved yet, but matches the next tile. This is a single merge
                // The last tile is *not* eligible for a merge
                let next = group[idx+1]
                let nv = v + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.singleCombine(source: next.getSource(), value: nv))
            case let t where (idx < group.count-1 && t.getValue() == group[idx+1].getValue()):
                // This tile has moved, and matches the next tile. This is a double merge
                // (The tile may either have moved prevously, or the tile might have moved as a result of a previous merge)
                // The last tile is *not* eligible for a merge
                let next = group[idx+1]
                let nv = t.getValue() + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.doubleCombine(source: t.getSource(), second: next.getSource(), value: nv))
            case let .noAction(s, v) where !GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s):
                // A tile that didn't move before has moved (first cond.), or there was a previous merge (second cond.)
                tokenBuffer.append(ActionToken.move(source: s, value: v))
            case let .noAction(s, v):
                // A tile that didn't move before still hasn't moved
                tokenBuffer.append(ActionToken.noAction(source: s, value: v))
            case let .move(s, v):
                // Propagate a move
                tokenBuffer.append(ActionToken.move(source: s, value: v))
            default:
                // Don't do anything
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







































