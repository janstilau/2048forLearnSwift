//
//  AuxiliaryModels.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import Foundation

enum MoveDirection{
    case Up, Down, Left, Right
}

// 存放滑动的方向,还有一个滑动结束后的block.这个block是写在手势的action函数里面的,在这个程序里面,是对2048这个游戏成功失败与否的判断.
struct MoveCommand{
    let direction: MoveDirection
    let completion: (Bool) -> Void
}


// 类似于optional的一个枚举类型,表明boardView的每一个格子里面有没有值
enum TileObject{
    case Empty
    case Tile(Int)
}

// 
struct SquareGameboard<T>{
    let dimension: Int
    var boardArray: [T]
    
    init(dimension d: Int, initialValue: T){
        dimension = d
        boardArray = [T].init(count: d * d, repeatedValue: initialValue)
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
    
    mutating func setAll(item: T){
        for i in 0..<dimension {
            for j in 0..<dimension{
                self[i, j] = item
            }
        }
    }
}






















































