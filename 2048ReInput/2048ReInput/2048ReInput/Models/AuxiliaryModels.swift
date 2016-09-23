//
//  AuxiliaryModels.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import Foundation

enum MoveDirection{
    case up, down, left, right
}

// 存放滑动的方向,还有一个滑动结束后的block.这个block是写在手势的action函数里面的,在这个程序里面,是对2048这个游戏成功失败与否的判断.
struct MoveCommand{
    let direction: MoveDirection
    let completion: (Bool) -> Void
}


// 类似于optional的一个枚举类型,表明boardView的每一个格子里面有没有值
enum TileObject{
    case empty
    case tile(Int)
}

// 
struct SquareGameboard<T>{
    let dimension: Int
    var boardArray: [T]
    
    init(dimension d: Int, initialValue: T){
        dimension = d
        boardArray = [T].init(repeating: initialValue, count: d * d)
    }
    
    
    subscript(row: Int, col: Int) -> T{
        get {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            return boardArray[row * dimension + col]
        }
        
        set{
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            boardArray[row * dimension + col] = newValue
        }
    }
    
    mutating func setAll(_ item: T){
        for i in 0..<dimension {
            for j in 0..<dimension{
                self[i, j] = item
            }
        }
    }
}


































/// An enum representing an intermediate result used by the game logic when figuring out how the board should change as
/// the result of a move. ActionTokens are transformed into MoveOrders before being sent to the delegate.
enum ActionToken {
    case noAction(source: Int, value: Int)
    case move(source: Int, value: Int)
    case singleCombine(source: Int, value: Int)
    case doubleCombine(source: Int, second: Int, value: Int)
    
    // Get the 'value', regardless of the specific type
    func getValue() -> Int {
        switch self {
        case let .noAction(_, v): return v
        case let .move(_, v): return v
        case let .singleCombine(_, v): return v
        case let .doubleCombine(_, _, v): return v
        }
    }
    // Get the 'source', regardless of the specific type
    func getSource() -> Int {
        switch self {
        case let .noAction(s, _): return s
        case let .move(s, _): return s
        case let .singleCombine(s, _): return s
        case let .doubleCombine(s, _, _): return s
        }
    }
}

/// An enum representing a 'move order'. This is a data structure the game model uses to inform the view controller
/// which tiles on the gameboard should be moved and/or combined.
enum MoveOrder {
    case singleMoveOrder(source: Int, destination: Int, value: Int, wasMerge: Bool)
    case doubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, value: Int)
}






















