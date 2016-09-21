//
//  GameboardView.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

class GameboardView: UIView {
    var dimension: Int
    var tileWidth: CGFloat
    var tilePadding: CGFloat
    var cornerRadius: CGFloat
    var tiles: Dictionary<NSIndexPath, TileView>
    
    let provider = AppearanceProvider() // 颜色管理
    
    let tilePopStartScale: CGFloat = 0.1 // insertTile的初始大小比例
    let tilePopMaxScale: CGFloat = 1.1 // 
    let tilePopDelay: NSTimeInterval = 0.05 // 滑动后多长时间insertTile
    let tileExpandTime: NSTimeInterval = 0.18 // insertTile放大时间
    let titleContractTime: NSTimeInterval = 0.08 // insertTile缩小时间
    
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: NSTimeInterval = 0.08 //合并放大时间
    let tileMergeContractTime: NSTimeInterval = 0.08 //合并缩小时间
    
    let perSquareSlideDuration: NSTimeInterval = 0.08 // 滑动时间
    
    init(dimension d: Int, tileWidth width: CGFloat, tilePadding padding: CGFloat, cornerRadius radius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor){
        assert(d > 0) // 在这个程序里面,经常看到guard,assert的代码.
        
        dimension = d
        tileWidth = width
        tilePadding = padding
        cornerRadius = radius
        tiles = Dictionary()
        let sideLength = padding + CGFloat(dimension)*(width + padding)
        super.init(frame: CGRectMake(0, 0, sideLength, sideLength))
        // swift后调用父类的初始化方法,倒是可以利用子类的属性计算需要生成的frame的大小了.如果是在oc环境下,首先调用父类的initWithFrame,然后根据属性再次计算,重新确定frame改变frame显得冗余.
        layer.cornerRadius = radius
        setupBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func reset(){
        for (_, tile) in tiles{
            tile.removeFromSuperview()
        }
        tiles.removeAll()
    }
    
    // 判断位置是否在boardView的范围之内.这个在移动,插入新框的时候每次都做检测.
    func positionIsValid(pos: (Int, Int)) -> Bool{
        let (x, y) = pos
        return (x >= 0 && x < dimension && y >= 0 && y < dimension)
    }
    
    func setupBackground(backgroundColor bgColor: UIColor, tileColor: UIColor){
        
        var xCursor = tilePadding
        var yCursor: CGFloat
        let bgRadius = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        for _ in 0..<dimension {
            yCursor = tilePadding
            for _ in 0..<dimension{
                let background = UIView.init(frame: CGRectMake(xCursor, yCursor, tileWidth, tileWidth))
                background.layer.cornerRadius = bgRadius
                background.backgroundColor = tileColor
                addSubview(background)
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int){
        
        assert(positionIsValid(from) && positionIsValid(to))
        let (fromRow, fromCol) = from
        let (toRow, toCol) = to
        let fromKey = NSIndexPath.init(forRow: fromRow, inSection: fromCol)
        let toKey = NSIndexPath.init(forRow: toRow, inSection: toCol)
        
        guard let tile = tiles[fromKey] else{
            assert(false, "Placeholder error")
        }
        let endTile = tiles[toKey]
        
        // Make the frame
        var finalFrame = tile.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)
        
        tiles.removeValueForKey(fromKey)
        tiles[toKey] = tile
        
        let shouldPop = endTile != nil
        UIView.animateWithDuration(perSquareSlideDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { 
            tile.frame = finalFrame
            }, completion: { (finish: Bool) -> Void in
                
                tile.value = value
                endTile?.removeFromSuperview()
                if !shouldPop || !finish{
                    return
                }
            tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
            UIView.animateWithDuration(self.tileMergeExpandTime, animations: { 
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                }, completion: { (finished) in
                    UIView.animateWithDuration(self.tileMergeContractTime, animations: { 
                        tile.layer.setAffineTransform(CGAffineTransformIdentity)
                    })
            })
        })
    }
    
    /// Update the gameboard by moving two tiles from their original locations to a common destination. This action always
    /// represents tile collapse, and the combined tile 'pops' after both tiles move into position.
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        let fromKeyA = NSIndexPath(forRow: fromRowA, inSection: fromColA)
        let fromKeyB = NSIndexPath(forRow: fromRowB, inSection: fromColB)
        let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
            assert(false, "placeholder error")
        }
        guard let tileB = tiles[fromKeyB] else {
            assert(false, "placeholder error")
        }
        
        // Make the frame
        var finalFrame = tileA.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)
        
        // Update the state
        let oldTile = tiles[toKey]  // TODO: make sure this doesn't cause issues
        oldTile?.removeFromSuperview()
        tiles.removeValueForKey(fromKeyA)
        tiles.removeValueForKey(fromKeyB)
        tiles[toKey] = tileA
        
        UIView.animateWithDuration(perSquareSlideDuration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.BeginFromCurrentState,
                                   animations: {
                                    // Slide tiles
                                    tileA.frame = finalFrame
                                    tileB.frame = finalFrame
            },
                                   completion: { finished in
                                    tileA.value = value
                                    tileB.removeFromSuperview()
                                    if !finished {
                                        return
                                    }
                                    tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                                    // Pop tile
                                    UIView.animateWithDuration(self.tileMergeExpandTime,
                                        animations: {
                                            tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                                        },
                                        completion: { finished in
                                            // Contract tile to original size
                                            UIView.animateWithDuration(self.tileMergeContractTime) {
                                                tileA.layer.setAffineTransform(CGAffineTransformIdentity)
                                            }
                                    })
        })
    }
    
    
    /// Update the gameboard by inserting a tile in a given location. The tile will be inserted with a 'pop' animation.
    func insertTile(pos: (Int, Int), value: Int) {
        assert(positionIsValid(pos))
        let (row, col) = pos
        let x = tilePadding + CGFloat(col)*(tileWidth + tilePadding)
        let y = tilePadding + CGFloat(row)*(tileWidth + tilePadding)
        let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        let tile = TileView(position: CGPointMake(x, y), width: tileWidth, value: value, radius: r, delegate: provider)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        
        addSubview(tile)
        bringSubviewToFront(tile)
        tiles[NSIndexPath(forRow: row, inSection: col)] = tile
        
        // Add to board
        UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone,
                                   animations: {
                                    // Make the tile 'pop'
                                    tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
            },
                                   completion: { finished in
                                    // Shrink the tile after it 'pops'
                                    UIView.animateWithDuration(self.titleContractTime, animations: { () -> Void in
                                        tile.layer.setAffineTransform(CGAffineTransformIdentity)
                                    })
        })
    }
    
    
}


























































