//
//  NumberTileGame.swift
//  2048Self
//
//  Created by jansti on 16/9/20.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit

class NumberTileGameViewController: UIViewController{
    
    var dimension: Int
    // the value of the winning tile
    var threshold: Int
    
    var board: GameBoardView?
    var model: GameModel?
    
    var scoreView: ScoreViewProtocol?

    let boardWidth: CGFloat = 230.0
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0
    
    let viewPadding: CGFloat = 10.0
    
    let verticalViewOffset: CGFloat = 0.0
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(dimension d: Int, threshold t: Int) {
        dimension = d > 2 ? d : 2
        threshold = t > 8 ? t : 8
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = UIColor.whiteColor()
        setupSwipeControls()
    }
    
    func setupSwipeControls() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("up:"))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("down:"))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("left:"))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("right:"))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    func setupGame(){
        
        let scoreView = ScoreView.init(backgroundColor: UIColor.greenColor(), textColor: UIColor.whiteColor(), font: UIFont.init(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFontOfSize(16.0), radius: 6)
        scoreView.score = 0
        
        let padding: CGFloat =  thickPadding
        let v1 = boardWidth - padding*(CGFloat(dimension + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
        let gameboard = GameBoardView(dimension: dimension,
                                      tileWidth: width,
                                      tilePadding: padding,
                                      cornerRadius: 6,
                                      backgroundColor: UIColor.blueColor(),
                                      foregroundColor: UIColor.yellowColor())
        
        let vcHeight = view.bounds.size.height
        let vcWidth = view.bounds.size.width
        
        // This nested function provides the x-position for a component view
        func xPositionToCenterView(v: UIView) -> CGFloat {
            let viewWidth = v.bounds.size.width
            let tentativeX = 0.5*(vcWidth - viewWidth)
            return tentativeX >= 0 ? tentativeX : 0
        }
        // This nested function provides the y-position for a component view
        func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat {
            assert(views.count > 0)
            assert(order >= 0 && order < views.count)
            //      let viewHeight = views[order].bounds.size.height
            let totalHeight = CGFloat(views.count - 1)*viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, combine: { $0 + $1 })
            let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0
            
            // Not sure how to slice an array yet
            var acc: CGFloat = 0
            for i in 0..<order {
                acc += viewPadding + views[i].bounds.size.height
            }
            return viewsTop + acc
        }
        
        // Set up the frames
        let views = [scoreView, gameboard]
        
        var f = scoreView.frame
        f.origin.x = xPositionToCenterView(scoreView)
        f.origin.y = yPositionForViewAtPosition(0, views: views)
        scoreView.frame = f
        
        f = gameboard.frame
        f.origin.x = xPositionToCenterView(gameboard)
        f.origin.y = yPositionForViewAtPosition(1, views: views)
        gameboard.frame = f

        // Add to game state
        view.addSubview(gameboard)
        board = gameboard
        view.addSubview(scoreView)
        self.scoreView = scoreView
//        
//        assert(model != nil)
//        let m = model!
//        m.insertTileAtRandomLocation(2)
//        m.insertTileAtRandomLocation(2)
    }
    
    
    
}






























































