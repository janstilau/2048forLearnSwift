//
//  AuxiliaryModels.swift
//  swift2048_THIRD
//
//  Created by jansti on 16/9/27.
//  Copyright © 2016年 jansti. All rights reserved.
//

import Foundation

enum MoveDirection {
    case up, down, left, right
}


struct MoveCommand {
    let direction: MoveDirection
    let completion: (Bool) -> ()
}


enum TileObject {
    case empty
    case tile(Int)
}


enum ActionToken {
    case noAction(source: Int, value: Int)
    case move(source: Int, value: Int)
    case singleCombine(source: Int, value: Int)
    case doubleCombine(source: Int, second: Int, value: Int)
    
    func getValue() -> Int{
        switch self {
        case let .noAction(_, v): return v
        case let .move(_, v): return v
        case let .singleCombine(_, v): return v
        case let .doubleCombine(_, _, v): return v
        }
    }
    
    func getSource() -> Int{
        switch self {
        case let .noAction(s, _): return s
        case let .move(s, _): return s
        case let .singleCombine(s, _): return s
        case let .doubleCombine(s, _, _): return s
        }
    }
}



enum MoveOrder {
    
    case singleMoveOrder(source: Int, destination: Int, value: Int, wasMerge: Bool)
    case doubleMoveOrder(firstSource: Int, secondSource: Int, destination: Int, value: Int)
}


struct SquareGameBoard<T> {
    
    let dimension: Int
    var boardArray: [T]
    
    init(dimension d: Int, initialValue: T) {
        dimension = d
        boardArray = [T].init(repeating: initialValue, count: d * d)
    }
    
    subscript(row: Int, col: Int) -> T{
        get {
            assert( row >= 0 && row < dimension)
            assert( col >= 0 && col < dimension)
            return boardArray[row*dimension + col]
        }
        set {
            assert( row >= 0 && row < dimension)
            assert( col >= 0 && col < dimension)
            boardArray[row*dimension + col] = newValue
        }
    }
    
    mutating func setAll(_ item: T){
        for i in 0..<dimension{
            for j in 0..<dimension{
                self[i,j] = item
            }
        }
    }
}





























