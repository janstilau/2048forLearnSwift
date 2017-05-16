//
//  ViewController.m
//  emitterDemo
//
//  Created by jansti on 16/10/9.
//  Copyright © 2016年 jansti. All rights reserved.
//

#import "ViewController.h"
#import "SnowView.h"


@interface ViewController ()

@property (nonatomic, strong) SnowView                *snow;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor blackColor];
////    [self addEmitterLayer];
//    
////    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 300, 300)];
////    redView.backgroundColor = [UIColor redColor];
//////    [self.view addSubview:redView];
////    redView.layer.borderColor = [[UIColor greenColor] CGColor];
////    redView.layer.borderWidth = 2.0;
//    
//    
////    UIImageView *imageView = [[UIImageView alloc] init];
////    imageView.image = [UIImage imageNamed:@"alpha"];
////    imageView.frame = CGRectMake(0, 0, 150, 150);
////    redView.maskView = imageView;
//    
//    
//    CALayer *maskLayer = [CALayer layer];
//    maskLayer.contents = (__bridge id)[UIImage imageNamed:@"alpha"].CGImage;
//    maskLayer.bounds = CGRectMake(0, 0, 150, 150);
//    maskLayer.anchorPoint = CGPointMake(0, 0);
////    redView.layer.mask = maskLayer;
//    
//    
//    self.snow = [[SnowView alloc] initWithFrame:CGRectMake(30, 30, 300, 300)];
//    [self.view addSubview:_snow];
//    
//    self.snow.snowImage  = [UIImage imageNamed:@"moon"];
////    self.snow.birthRate  = 20.f;
////    self.snow.gravity    = 5.f;
//    self.snow.snowColor  = [UIColor whiteColor];
//    
//    [self.snow showSnow];
    
    
    
    
    [self makeFireWorkDisplay];
}


- (void)makeFireWorkDisplay{
    
    // 粒子发射系统 的初始化
    CAEmitterLayer *fireworksEmitter = [CAEmitterLayer layer];
    CGRect viewBounds = self.view.layer.bounds;
    fireworksEmitter.backgroundColor = [[UIColor greenColor] CGColor];
    // 发射源的位置
    fireworksEmitter.emitterPosition = CGPointMake(viewBounds.size.width/2.0, viewBounds.size.height);
    // 发射源尺寸大小
    fireworksEmitter.emitterSize = CGSizeMake(viewBounds.size.width/2.0, 0.0);
    // 发射模式
    fireworksEmitter.emitterMode = kCAEmitterLayerOutline;
    // 发射源的形状
    fireworksEmitter.emitterShape = kCAEmitterLayerLine;
    // 发射源的渲染模式
    fireworksEmitter.renderMode = kCAEmitterLayerAdditive;
    // 发射源初始化随机数产生的种子
    fireworksEmitter.seed = (arc4random()%100)+1;
    
    /**
     *  添加发射点
     一个圆（发射点）从底下发射到上面的一个过程
     */
    CAEmitterCell* rocket  = [CAEmitterCell emitterCell];
    rocket.birthRate = 1.0; //是每秒某个点产生的effectCell数量
    rocket.emissionRange = 0.25 * M_PI; // 周围发射角度
    rocket.velocity = 100; // 速度
    rocket.velocityRange = 500; // 速度范围
    rocket.yAcceleration = 20; // 粒子y方向的加速度分量
    rocket.lifetime = 1.02; // effectCell的生命周期，既在屏幕上的显示时间要多长。
    
    // 下面是对 rocket 中的内容，颜色，大小的设置
    rocket.contents = (id) [[UIImage imageNamed:@"moon"] CGImage];
    rocket.scale = 0.2;
    rocket.color = [[UIColor redColor] CGColor];
//    rocket.greenRange = 1.0;
//    rocket.redRange = 1.0;
//    rocket.blueRange = 1.0;
    rocket.spinRange = M_PI; // 子旋转角度范围
    
    /**
     * 添加爆炸的效果，突然之间变大一下的感觉
     */
    CAEmitterCell* burst = [CAEmitterCell emitterCell];
    burst.birthRate = 1.0;
    burst.velocity = 0;
    burst.scale = 2.5;
    
//    burst.redSpeed =-20;
//    burst.blueSpeed =+1.5;
//    burst.greenSpeed =+1.0;
    burst.lifetime = 0.35;
    
    /**
     *  添加星星扩散的粒子
     */
    CAEmitterCell* spark = [CAEmitterCell emitterCell];
    spark.birthRate = 400;
    spark.velocity = 125;
    spark.emissionRange = 2* M_PI;
    spark.yAcceleration = 75; //粒子y方向的加速度分量
    spark.lifetime = 3;
    
    spark.contents = (id) [[UIImage imageNamed:@"moon"] CGImage];
    spark.scaleSpeed =-0.2;
    spark.greenSpeed =-0.1;
    spark.redSpeed = 0.4;
    spark.blueSpeed =-0.1;
    spark.alphaSpeed =-0.25; // 例子透明度的改变速度
    spark.spin = 2* M_PI; // 子旋转角度
    spark.spinRange = 2* M_PI;
    
    // 将 CAEmitterLayer 和 CAEmitterCell 结合起来
    fireworksEmitter.emitterCells = [NSArray arrayWithObject:rocket];
    //在圈圈粒子的基础上添加爆炸粒子
    rocket.emitterCells = [NSArray arrayWithObject:burst];
    //在爆炸粒子的基础上添加星星粒子
    burst.emitterCells = [NSArray arrayWithObject:spark];
    // 添加到图层上
    [self.view.layer addSublayer:fireworksEmitter];
    
    
}

- (void)addEmitterLayer{
    
    CAEmitterLayer *snowEmitterLayer = [CAEmitterLayer layer];
    snowEmitterLayer.emitterPosition = CGPointMake(self.view.bounds.size.width * 0.5, 20);
    snowEmitterLayer.emitterSize = CGSizeMake(self.view.bounds.size.width * 2.0, 0);
    
    snowEmitterLayer.emitterMode = kCAEmitterLayerOutline;
    snowEmitterLayer.emitterShape = kCAEmitterLayerLine;
    
    snowEmitterLayer.shadowOpacity = 1.0;
    snowEmitterLayer.shadowRadius = 2.0;
    snowEmitterLayer.shadowOffset = CGSizeMake(4.0, 5.0);
    snowEmitterLayer.shadowColor = [[UIColor redColor] CGColor];
    
    snowEmitterLayer.emitterCells = [NSArray arrayWithObject:[self createSnowCell]];
    
    // 添加到layer
    [self.view.layer insertSublayer:snowEmitterLayer atIndex:0];
    
}

- (CAEmitterCell *)createSnowCell {
    // 创建粒子单元
    CAEmitterCell *snowCell = [CAEmitterCell emitterCell];
    
    snowCell.contents = (id)[[UIImage imageNamed:@"ss.png"] CGImage];
    
    snowCell.birthRate = 1.0f;// 每秒生成例子频率
    snowCell.lifetime = 120.f; // 粒子系统的生命周期
    
    snowCell.velocity = -10;   // 粒子速度
    snowCell.velocityRange = 10; // 粒子速度范围
    snowCell.yAcceleration = 2; // 粒子y方向的加速度分量
    snowCell.emissionRange = 0.5 * M_PI; // 周围发射角度
    snowCell.spinRange = 0.25 * M_PI;  // 旋转角度
    snowCell.contents = (id)[[UIImage imageNamed:@"Snow"] CGImage]; // 粒子显示内容
    snowCell.color = [[UIColor colorWithRed:0.600 green:0.658 blue:0.743 alpha:1.000] CGColor]; // 粒子颜色
    
    return snowCell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
