//
//  GAMGCManager.h
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/6.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "GameCenter.h"

@interface GAMGCManager : NSObject

+(void)initGameCenter:(ViewController *)viewController;
+(void)updateGameCenterRankingInDifLevel:(GameDifficultyLevel)difLevel isPerfect:(BOOL)isPerfect;
+(void)showGameCenterWithController:(ViewController *)viewController difflevel:(GameDifficultyLevel)difflevel;
@end
