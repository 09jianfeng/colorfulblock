//
//  SpriteUIView.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/26.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "SpriteUIView.h"
#import "macro.h"

@interface SpriteUIView()
@property(nonatomic, retain) NSTimer * timer;
@end

@implementation SpriteUIView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)generateBehaviorAndAdd:(UIDynamicAnimator *)animator{
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self]];
    _itemBehavior.density = 800.0/(self.frame.size.height*self.frame.size.width);
    _itemBehavior.elasticity = 0.0;
    _itemBehavior.friction = 0.0;
    _itemBehavior.resistance = 0.0;
    _itemBehavior.allowsRotation = YES;
    
    //随机旋转方向，推力随机向量
    int randx = arc4random()%(35*2) - 35;
    [self.pushBehavior setPushDirection:CGVectorMake(randx/100.0, -1*(0.3))];
    self.transform = CGAffineTransformMakeRotation(M_PI*(randx/100.0));
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerResponder:) userInfo:nil repeats:YES];
    [self addBehaviorWithAnimator:animator];
}

-(void)addBehaviorWithAnimator:(UIDynamicAnimator *)animator{
    if (animator) {
        [animator addBehavior:self.pushBehavior];
        [animator addBehavior:self.itemBehavior];
    }
}

-(void)removeBehaviorWithAnimator:(UIDynamicAnimator *)animator{
    if (animator) {
        [self.pushBehavior removeItem:self];
        [self.itemBehavior removeItem:self];
        [animator removeBehavior:self.pushBehavior];
        [animator removeBehavior:self.itemBehavior];
    }
}

-(void)timerResponder:(id)sender{
    //演员初始化
    CALayer* scaleLayer = [[CALayer alloc] init];
    scaleLayer.contents = self.layer.contents;
    scaleLayer.opacity = 0.8;
    scaleLayer.frame = CGRectMake(self.frame.origin.x + self.frame.size.width/4, self.frame.origin.y, self.frame.size.width/2, self.frame.size.height/2);
    scaleLayer.cornerRadius = 10;
    [self.superview.layer addSublayer:scaleLayer];
    
    //设定剧本
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.0];
    //自动按照原来的轨迹往回播动画
    scaleAnimation.autoreverses = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.repeatCount = 0;
    scaleAnimation.duration = 0.3;
    //这个delegate会让self的retainCount加1
    scaleAnimation.delegate = self;
    scaleAnimation.removedOnCompletion = NO;
    [scaleAnimation setValue:scaleLayer forKey:@"MyScaleLayerType"];
    //开演
    [scaleLayer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

//动画开始
-(void)animationDidStart:(CAAnimation *)anim{
    
}

//动画结束
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        CALayer *layer = [anim valueForKey:@"MyScaleLayerType"];
        if (layer) {
            //这里必须要removeAnimation，才能令self的retain减一
            [layer removeAllAnimations];
            [layer removeFromSuperlayer];
        }
    }
}

-(void)setTimeInvilade{
    [self.timer invalidate];
}

-(void)dealloc{
    HNLOGINFO(@"block dealloc");
    [self.timer invalidate];
    self.timer = nil;
    self.pushBehavior = nil;
    self.itemBehavior = nil;
}
@end
