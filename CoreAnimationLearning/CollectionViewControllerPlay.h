//
//  CollectionViewControllerPlay.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/24.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface CollectionViewControllerPlay : UICollectionViewController
//是否要背景图片
@property(nonatomic, assign) BOOL noBackgroundImage;
//横向的方块个数
@property(nonatomic, assign) float widthNum;
//初始颜色个数
@property(nonatomic, assign) int gameInitTypeNum;
//游戏结束时间
@property(nonatomic, assign) float timeLimit;
//第几关。用来获取过关的分数
@property(nonatomic, assign) GameDifficultyLevel gameDifficultyLevel;

-(void)exitTheGame;
-(void)contiuneTheGame;
-(void)replayTheGame;
@end
