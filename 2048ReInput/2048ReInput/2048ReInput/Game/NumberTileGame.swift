//
//  NumberTileGame.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit


//: 游戏的主控制类.联合gameModel和gameboardView.gameModel里面控制数据,包含所有的棋盘里面的数据,每次手指在屏幕上进行滑动,控制器都会调用model的方法更新数据,在更新完数据之后,model会告诉自己的代理,也就是本控制器数据更新完成,然后,控制器会调用gameBoardView的方法进行动画改变屏幕的显示.所以,主要的合并,移动位置的操作在model类之中,而展示,动画的效果在boardView上展示.


class NumberTileGameViewController: UIViewController, GameModelProtocol{
    
    var dimension: Int
    var threshold: Int
    
    var board: GameboardView?
    var model: GameModel?
    
    var scoreView: ScoreViewProtocol?
    
    let boardWidth: CGFloat = 230.0
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0
    
    let viewPadding: CGFloat = 10.0
    
    let verticalViewOffset: CGFloat = 0.0
    
    init(dimension d: Int, threshold t:Int){
        dimension = d > 2 ? d : 2
        threshold = t > 8 ? t : 8
        super.init(nibName: nil, bundle: nil)
        model = GameModel(dimension: dimension, threshold: threshold, delegate: self)
        view.backgroundColor = UIColor.whiteColor()
        setupSwipeControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
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
    
    
    
    func setupGame() {
        let vcHeight = view.bounds.size.height
        let vcWidth = view.bounds.size.width
        
        
        func xPositionToCenterView(v: UIView) -> CGFloat{
            let viewWidth = v.bounds.size.width
            let tentativeX = 0.5*(vcWidth - viewWidth)
            
            return tentativeX >= 0 ? tentativeX: 0
        }
        
        func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat{
            assert(views.count > 0)
            assert(order >= 0 && order < views.count)
            
            let totalHeight = CGFloat(views.count - 1) * viewPadding +
                views.map({ $0.bounds.size.height}).reduce(verticalViewOffset, combine: { $0 + $1})
            let viewsTop = 0.5*(vcHeight - totalHeight) >= 0 ? 0.5*(vcHeight - totalHeight) : 0
            
            var acc: CGFloat = 0
            for i in 0..<order {
                acc += viewPadding + views[i].bounds.size.height
            }
            return viewsTop + acc
        }
        
        let scoreView = ScoreView.init(backgroundColor: UIColor.redColor(), textColor: UIColor.whiteColor(), font: UIFont.init(name: "HelveticaNeur-Bold", size: 16.0) ?? UIFont.systemFontOfSize(16.0), radius: 6)
        scoreView.score = 0
    
        // Create the gameboard
        let padding: CGFloat = dimension > 5 ? thinPadding : thickPadding
        let v1 = boardWidth - padding*(CGFloat(dimension + 1))
        let width: CGFloat = CGFloat(floorf(CFloat(v1)))/CGFloat(dimension)
        let gameboard = GameboardView.init(dimension: dimension, tileWidth: width, tilePadding: padding, cornerRadius: 6, backgroundColor: UIColor.blueColor(), foregroundColor: UIColor.yellowColor())
        
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
        
    }
    
    func followUp() {
        
    }
    
    // Commands
    @objc(up:)
    func upCommand(r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Up,
                    completion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    @objc(down:)
    func downCommand(r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Down,
                    completion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    @objc(left:)
    func leftCommand(r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Left,
                    completion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    @objc(right:)
    func rightCommand(r: UIGestureRecognizer!) {
        assert(model != nil)
        let m = model!
        m.queueMove(MoveDirection.Right,
                    completion: { (changed: Bool) -> () in
                        if changed {
                            self.followUp()
                        }
        })
    }
    
    
    
    // Protocol
    func scoreChanged(score: Int) {
        if scoreView == nil {
            return
        }
        let s = scoreView!
        s.scoreChanged(newScore: score)
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveOneTile(from, to: to, value: value)
    }
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.moveTwoTiles(from, to: to, value: value)
    }
    
    func insertTile(location: (Int, Int), value: Int) {
        assert(board != nil)
        let b = board!
        b.insertTile(location, value: value)
    }
    
}






































