//
//  GAMGCManager.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/6.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "GAMGCManager.h"
#import "GameCenterManager.h"
#import "GameResultData.h"

#define EASYMODEL 101
#define NORMALMODEL 102
#define DIFFICULTMODEL 103
#define CRAZYMODEL 104
#define PERFECTTIMES 105

extern NSString *GAMEBESTPOINTKEY;
extern NSString *GAMEPEFECTTIMESKET;

@implementation GAMGCManager

+(void)initGameCenter{
    [[GameCenterManager sharedManager] setupManager];
    //加密数据的秘钥，这个秘钥升级的时候不能变。否则会崩溃
    [[GameCenterManager sharedManager] setupManagerAndSetShouldCryptWithKey:@"3ufdekid"];
}

+(void)updateGameCenterRankingInDifLevel:(GameDifficultyLevel)difLevel isPerfect:(BOOL)isPerfect{
    NSArray *arrayGameResult = [GameResultData getDictionaryOfGameResult];
    int bestPoint = [[[arrayGameResult objectAtIndex:difLevel] objectForKey:GAMEBESTPOINTKEY] intValue];
    [[GameCenterManager sharedManager] saveAndReportScore:bestPoint leaderboard:[NSString stringWithFormat:@"%d",EASYMODEL+difLevel] sortOrder:GameCenterSortOrderHighToLow];
    
    if (isPerfect) {
        int allPerfectTimes = 0;
        for (int i=0; i < 4; i++) {
            int perfectTimes = [[[arrayGameResult objectAtIndex:i] objectForKey:GAMEPEFECTTIMESKET] intValue];
            allPerfectTimes += perfectTimes;
        }
        [[GameCenterManager sharedManager] saveAndReportScore:bestPoint leaderboard:[NSString stringWithFormat:@"%d",PERFECTTIMES] sortOrder:GameCenterSortOrderHighToLow];
    }
}

+(void)showGameCenterWithController:(UIViewController *)viewController difflevel:(GameDifficultyLevel)difflevel{
    BOOL isAvaliable = [[GameCenterManager sharedManager] checkGameCenterAvailability:YES];
    if (isAvaliable) {
        [[GameCenterManager sharedManager] presentLeaderboardsOnViewController:viewController withLeaderboard:[NSString stringWithFormat:@"%d",EASYMODEL+difflevel]];
    }
}

@end
