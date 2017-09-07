//
//  GAMGCManager.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/6.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "GAMGCManager.h"
#import "GameResultData.h"
#import "GameCenter.h"

#define EASYMODEL 101
#define NORMALMODEL 102
#define DIFFICULTMODEL 103
#define CRAZYMODEL 104
#define PERFECTTIMES 105

extern NSString *GAMEBESTPOINTKEY;
extern NSString *GAMEPEFECTTIMESKET;

@interface GAMGCManager()
@property(nonatomic, retain) GameCenter *gameCenter;
@end

@implementation GAMGCManager
+(id)shareInstance{
    static GAMGCManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GAMGCManager new];
    });
    
    return instance;
}

-(id)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.gameCenter = [GameCenter new];
    self.gameCenter.delegate = self;
    [self.gameCenter authenticateLocalPlayer];
    
    return self;
}

+(void)initGameCenter:(ViewController *)viewController{
//    [GAMGCManager shareInstance];
//    [[[GAMGCManager shareInstance] gameCenter]setViewController:viewController];
}

+(void)updateGameCenterRankingInDifLevel:(GameDifficultyLevel)difLevel isPerfect:(BOOL)isPerfect{
//    NSArray *arrayGameResult = [GameResultData getDictionaryOfGameResult];
//    int bestPoint = [[[arrayGameResult objectAtIndex:difLevel] objectForKey:GAMEBESTPOINTKEY] intValue];
//    [[[GAMGCManager shareInstance] gameCenter] reportScore:bestPoint forCategory:[NSString stringWithFormat:@"%d",EASYMODEL+difLevel]];
//    
//    if (isPerfect) {
//        int allPerfectTimes = 0;
//        for (int i=0; i < 4; i++) {
//            int perfectTimes = [[[arrayGameResult objectAtIndex:i] objectForKey:GAMEPEFECTTIMESKET] intValue];
//            allPerfectTimes += perfectTimes;
//        }
//
//        [[[GAMGCManager shareInstance] gameCenter] reportScore:allPerfectTimes forCategory:[NSString stringWithFormat:@"%d",PERFECTTIMES]];
//    }
}

+(void)showGameCenterWithController:(ViewController *)viewController difflevel:(GameDifficultyLevel)difflevel{
//    [[[GAMGCManager shareInstance] gameCenter] setViewController:viewController];
//    [[[GAMGCManager shareInstance] gameCenter] showGameCenter];
}
@end
