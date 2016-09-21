//
//  AuxiliaryModels.swift
//  2048Self
//
//  Created by jansti on 16/9/20.
//  Copyright © 2016年 jansti. All rights reserved.
//

import Foundation


/// An enum representing either an empty space or a tile upon the board.
enum TileObject {
    case Empty
    case Tile(Int)
}

enum MoveDirection {
    case Up, Down, Left, Right
}

/// An enum representing a movement command issued by the view controller as the result of the user swiping.
struct MoveCommand {
    let direction : MoveDirection
    let completion : (Bool) -> ()
}



struct SquareGameboard<T>{
    
    let dimension: Int
    var boardArray: [T]
    
    init(dimension d: Int, initialValue: T){
        dimension = d
        boardArray = [T].init(count: d*d, repeatedValue: initialValue)
    }
    
    subscript(row: Int, col: Int) -> T{
        get {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && row < dimension)
            return boardArray[row * dimension + col]
        }
        
        set {
            assert(row >= 0 && row < dimension)
            assert(col >= 0 && col < dimension)
            boardArray[row*dimension + col] = newValue
        }
    }
    
    mutating func setAll(item: T){
        for i in 0..<dimension{
            for j in 0..<dimension{
                self[i, j] = item
            }
        }
    }
}




























