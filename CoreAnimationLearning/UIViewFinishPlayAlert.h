//
//  UIViewFinishPlayAlert.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/5/27.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewControllerPlay.h"

@protocol UIViewFinishPlayAlertDelegate <NSObject>
@required
-(void)numFirstAddingAnimationFinish;
@end

@interface UIViewFinishPlayAlert : UIView
@property(nonatomic, assign) CollectionViewControllerPlay<UIViewFinishPlayAlertDelegate> *collectionViewController;
@property(nonatomic, assign) int gameCurrentPoints;
@property(nonatomic, assign) BOOL isPerfectPlay;
@property(nonatomic, assign) BOOL isGameEnd;
@property(nonatomic, assign) BOOL isHistoryBest;
@property(nonatomic, assign) float gameTimeLimit;
@property(nonatomic, assign) float gameCurrentProgressTime;
@property(nonatomic, assign) float gameResultPoints;

-(void)showView;
@end
