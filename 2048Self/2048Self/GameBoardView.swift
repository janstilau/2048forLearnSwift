//
//  GameBoardView.swift
//  2048Self
//
//  Created by jansti on 16/9/20.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit


class GameBoardView: UIView{
    
    var dimension: Int
    var tileWidth: CGFloat
    var tilePadding: CGFloat
    var cornerRadius: CGFloat
    var tiles: Dictionary<NSIndexPath, TileView>
    
    
    let provider = AppearanceProvider()
    
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tilePopDelay: NSTimeInterval = 0.05
    let tileExpandTime: NSTimeInterval = 0.18
    let tileContractTime: NSTimeInterval = 0.08
    
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: NSTimeInterval = 0.08
    let tileMergeContractTime: NSTimeInterval = 0.08
    
    let perSquareSlideDuration: NSTimeInterval = 0.08
    
    init(dimension d: Int, tileWidth width: CGFloat, tilePadding padding: CGFloat, cornerRadius radius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor) {
        
        assert(d > 0)
        dimension = d
        tileWidth = width
        tilePadding = padding
        cornerRadius = radius
        tiles = Dictionary()
        let sideLength = padding + CGFloat(dimension) * (width + padding)
        super.init(frame: CGRectMake(0, 0, sideLength, sideLength))
        layer.cornerRadius = radius
        setupBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground(backgroundColor bgColor: UIColor, tileColor: UIColor){
        backgroundColor = bgColor
        var xCursor = tilePadding
        var yCursor : CGFloat
        let bgRadius = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        
        for _ in 0..<dimension {
            yCursor = tilePadding
            for _ in 0..<dimension {
                // Draw each tile
                let background = UIView(frame: CGRectMake(xCursor, yCursor, tileWidth, tileWidth))
                background.layer.cornerRadius = bgRadius
                background.backgroundColor = tileColor
                addSubview(background)
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
    }
    
    func positionIsValid(pos: (Int, Int)) -> Bool {
        let (x, y) = pos
        return (x >= 0 && x < dimension && y >= 0 && y < dimension)
    }
    
    
    func insertTile(pos: (Int, Int), value: Int){
        assert(positionIsValid(pos))
        let (row, col) = pos
        let x = tilePadding + CGFloat(col) * (tileWidth + tilePadding)
        let y = tilePadding + CGFloat(row) * (tileWidth + tilePadding)
        let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        
        let tile = TileView.init(position: CGPointMake(x, y), width: tileWidth, value: value, radius: r, delegate: provider)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        addSubview(tile)
        bringSubviewToFront(tile)
        tiles[NSIndexPath.init(forRow: row, inSection: col)] = tile
        
        UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone, animations: { 
            tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
            }) { (finished) in
                UIView.animateWithDuration(self.tileContractTime, animations: {
                    tile.layer.setAffineTransform(CGAffineTransformIdentity)
                })
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
