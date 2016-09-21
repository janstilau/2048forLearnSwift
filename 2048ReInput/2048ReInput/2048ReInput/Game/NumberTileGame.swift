//
//  NumberTileGame.swift
//  2048ReInput
//
//  Created by jansti on 16/9/21.
//  Copyright © 2016年 jansti. All rights reserved.
//

import UIKit


//: 游戏的主控制类.联合gameModel和gameboardView.gameModel里面控制数据,包含所有的棋盘里面的数据,每次手指在屏幕上进行滑动,控制器都会调用model的方法更新数据,在更新完数据之后,model会告诉自己的代理,也就是本控制器数据更新完成,然后,控制器会调用gameBoardView的方法进行动画改变屏幕的显示.所以,主要的合并,移动位置的操作在model类之中,而展示,动画的效果在boardView上展示.


class NumberTileGameViewController: UIViewController{
    
    
    
    
    
    init(dimension d: Int, threshold t:Int){
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
}






































