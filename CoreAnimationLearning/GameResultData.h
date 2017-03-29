//
//  GameResultData.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/5/31.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface GameResultData : NSObject
//如果有更新bestPoints值，则返回true
+(BOOL)setGameResultForDifLevel:(GameDifficultyLevel)difLevel bestPoints:(int)bestPoints isPerfectPlay:(BOOL)isPerfectPlay;
+(int)getBestPointsForDifLevel:(GameDifficultyLevel)difLevel;
+(int)getPerfectTimesForDifLevel:(GameDifficultyLevel)difLevel;
+(NSArray *)getDictionaryOfGameResult;

@end
