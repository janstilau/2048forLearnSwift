//
//  GameboardView.swift
//  swift2048_THIRD
//
//  Created by jansti on 16/9/27.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

class GameboardView: UIView {
    var dimension: Int
    var tileWidth: CGFloat
    var tilePadding: CGFloat
    var cornerRadius: CGFloat
    var tiles: Dictionary<IndexPath, TileView>
    
    let provider = AppearanceProvider()
    
    // 可以设置默认值是很方便的一件事,想象一下在oc里面,如果想让属性存储一些值,那么这些值只能在viewDidLoad里面专门写一个方法设置默认值.而且在重看代码的时候,由于不在一起,思路不连贯.
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tilePopDelay: TimeInterval = 0.05
    let tileExpandTime: TimeInterval = 0.18
    let tileContractTime: TimeInterval = 0.08
    
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: TimeInterval = 0.08
    let tileMergeContractTime: TimeInterval = 0.08
    
    let perSquareSlideDuration: TimeInterval = 0.08
    
    init(dimension d: Int, tileWidth width: CGFloat, tilePadding padding: CGFloat, cornerRadius radius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor){
        
        assert(d > 0)
        dimension = d
        tileWidth = width
        tilePadding = padding
        cornerRadius = radius
        tiles = Dictionary()
        
        let sideLength = padding + CGFloat(dimension) * (width + padding)
        super.init(frame: CGRect.init(x: 0, y: 0, width: sideLength, height: sideLength))
        layer.cornerRadius = radius
        setupBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground(backgroundColor bgColor: UIColor, tileColor: UIColor){
        backgroundColor = bgColor
        var xCursor = tilePadding
        var yCursor: CGFloat = 0.0
        let bgRadius = (cornerRadius >= 2) ? cornerRadius - 2: 0
        for _ in 0..<dimension{
            yCursor = tilePadding
            for _ in 0..<dimension {
                let background = UIView.init(frame: CGRect.init(x: xCursor, y: yCursor, width: tileWidth, height: tileWidth))
                background.layer.cornerRadius = bgRadius
                background.backgroundColor = tileColor
                addSubview(background)
                yCursor = tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
    }
    
    func reset() {
        for (_, tile) in tiles{
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepingCapacity: true)
    }
    
    func positionIsValid(_ pos: (Int, Int)) -> Bool {
        let (x, y) = pos
        return (x >= 0 && x < dimension && y >= 0 && y < dimension)
    }
    
    func insertTile(_ pos: (Int, Int), value: Int) {
        assert(positionIsValid(pos))
        let (row, col) = pos
        let x = tilePadding + CGFloat(col) * (tileWidth + tilePadding)
        let y = tilePadding + CGFloat(row) * (tileWidth + tilePadding)
        let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        let tile = TileView.init(position: CGPoint.init(x: x, y: y), width: tileWidth, value: value, radius: r, delegate: provider)
        tile.layer.setAffineTransform(CGAffineTransform.init(scaleX: tilePopStartScale, y: tilePopStartScale))
        
        addSubview(tile)
        bringSubview(toFront: tile)
        tiles[IndexPath.init(row: row, section: col)] = tile
        
        UIView.animate(withDuration: tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions(), animations: { 
            tile.layer.setAffineTransform(CGAffineTransform.init(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
        }) { (finished: Bool) in
                UIView.animate(withDuration: self.tileContractTime, animations: { 
                    tile.layer.setAffineTransform(CGAffineTransform.identity)
                })
        }
    }
    
    func moveOneTile(_ from: (Int, Int), to: (Int, Int) ,value: Int) {
        
        assert(positionIsValid(from) && positionIsValid(to))
        let (fromRow, fromCol) = from
        let (toRow, toCol) = to
        let fromKey = IndexPath.init(row: fromRow, section: fromCol)
        let toKey = IndexPath.init(row: toRow, section: toCol)
        
        guard let tile = tiles[fromKey] else {
            assert(false, "placeHolder error")
        }
        let endTile = tiles[toKey]
        
        var finalFrame = tile.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol) * (tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow) * (tileWidth + tilePadding)
        tiles.removeValue(forKey: fromKey)
        
        let shouldPop = endTile != nil
        UIView.animate(withDuration: perSquareSlideDuration, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { 
            tile.frame = finalFrame
        }) { (finished: Bool) in
                tile.value = value
                endTile?.removeFromSuperview()
            
            if !shouldPop || !finished {
                return
            }
            
            tile.layer.setAffineTransform(CGAffineTransform.init(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
            UIView.animate(withDuration: self.tileMergeExpandTime, animations: { 
                tile.layer.setAffineTransform(CGAffineTransform.init(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
                }, completion: { (finished) in
                    UIView.animate(withDuration: self.tileMergeContractTime, animations: { 
                        tile.layer.setAffineTransform(CGAffineTransform.identity)
                    })
            })
        }
    }
    
    func moveTwoTiles(_ from: ((Int , Int), (Int, Int)), to: (Int, Int), value: Int ){
        
        assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        let fromKeyA = IndexPath.init(row: fromRowA, section: fromColA)
        let fromKeyB = IndexPath.init(row: fromRowB, section: fromColB)
        let toKey = IndexPath.init(row: toRow, section: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
            assert(false, "placeHolder error")
        }
        guard let tileB = tiles[fromKeyB] else {
            assert(false, "placeHolder error")
        }
        
        var finalFrame = tileA.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol) * (tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow) * (tileWidth + tilePadding)
        
        let oldTile = tiles[toKey]
        oldTile?.removeFromSuperview()
        tiles.removeValue(forKey: fromKeyA)
        tiles.removeValue(forKey: fromKeyB)
        tiles[toKey] = tileA
        
        UIView.animate(withDuration: perSquareSlideDuration, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { 
            tileA.frame = finalFrame
            tileB.frame = finalFrame
            }) { (finished) in
                tileA.value = value
                tileB.removeFromSuperview()
                if !finished{
                    return
                }
                tileA.layer.setAffineTransform(CGAffineTransform.init(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
                UIView.animate(withDuration: self.tileMergeExpandTime, animations: { 
                    tileA.layer.setAffineTransform(CGAffineTransform.init(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
                    }, completion: { (finished) in
                        UIView.animate(withDuration: self.tileMergeContractTime, animations: { 
                            tileA.layer.setAffineTransform(CGAffineTransform.identity)
                        })
                })
        }
    }
}





































