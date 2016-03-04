//
//  UIViewFinishPlayAlert.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/5/27.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewControllerPlay.h"

@interface UIViewFinishPlayAlert : UIView
@property(nonatomic,assign) CollectionViewControllerPlay *collectionViewController;
@property(nonatomic,assign) int gameCurrentPoints;
@property(nonatomic,assign) BOOL isPerfectPlay;
@property(nonatomic,assign) BOOL isGameEnd;

-(void)showView;
@end
