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
+(void)setGameResultForDifLevel:(GameDifficultyLevel)difLevel bestPoints:(int)bestPoints isPerfectPlay:(BOOL)isPerfectPlay;
+(int)getBestPointsForDifLevel:(GameDifficultyLevel)difLevel;
+(int)getPerfectTimesForDifLevel:(GameDifficultyLevel)difLevel;
@end
