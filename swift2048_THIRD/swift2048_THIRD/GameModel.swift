
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
        if case .empty = gameboard[x, y]{
            
        }
    }
    
    
    func performMove(_ direction: MoveDirection) -> Bool {
        return true
    }
    
    
}







































