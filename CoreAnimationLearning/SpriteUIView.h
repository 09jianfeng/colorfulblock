//
//  SpriteUIView.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/26.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpriteUIView : UIView
@property(nonatomic, retain)UIPushBehavior *pushBehavior;
@property(nonatomic, retain)UIDynamicItemBehavior *itemBehavior;

-(void)generateBehaviorAndAdd:(UIDynamicAnimator *)animator;
-(void)removeBehaviorWithAnimator:(UIDynamicAnimator *)animator;
-(void)setTimeInvilade;
@end
