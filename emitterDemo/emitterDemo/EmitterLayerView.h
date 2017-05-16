//
//  EmitterLayerView.h
//  emitterDemo
//
//  Created by jansti on 16/10/9.
//  Copyright © 2016年 jansti. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    __SNOW = 0X11,
    __RAIN,
    __NONE
} EMitterType;

@interface EmitterLayerView : UIView
// 275818865

- (void)setEmitterLayer:(CAEmitterLayer *)layer;
- (CAEmitterLayer *)emitterLayer;

- (void)show;
- (void)hide;
- (void)configType:(EMitterType)type;

@end
