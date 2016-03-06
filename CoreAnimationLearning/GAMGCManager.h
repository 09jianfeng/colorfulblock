//
//  GAMGCManager.h
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/6.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface GAMGCManager : NSObject

+(void)initGameCenter;
+(void)updateGameCenterRankingInDifLevel:(GameDifficultyLevel)difLevel isPerfect:(BOOL)isPerfect;
+(void)showGameCenterWithController:(UIViewController *)viewController difflevel:(GameDifficultyLevel)difflevel;
@end
