//
//  GameResultData.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/5/31.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "GameResultData.h"
#import "GameKeyValue.h"

NSString *GAMERESULTDATAKEY = @"GAMERESULTDATAKEY";
NSString *GAMEBESTPOINTKEY = @"GAMEBESTPOINTKEY";
NSString *GAMEPEFECTTIMESKET = @"GAMEPEFECTTIMESKET";

@interface GameResultData()
@property(nonatomic, retain) NSMutableArray *mutableArrayGameResult;
@end

@implementation GameResultData
+(id)shareInstance{
    static GameResultData *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [GameResultData new];
    });
    return shareInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        self.mutableArrayGameResult = [GameKeyValue objectForKey:GAMERESULTDATAKEY];
        if (!self.mutableArrayGameResult) {
            self.mutableArrayGameResult = [[NSMutableArray alloc] initWithCapacity:4];
            for (int i = 0; i < 4; i++) {
                NSMutableDictionary *dictionaryDifLevel = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",GAMEBESTPOINTKEY,@"0",GAMEPEFECTTIMESKET, nil];
                [self.mutableArrayGameResult addObject:dictionaryDifLevel];
            }
            [GameKeyValue setObject:self.mutableArrayGameResult forKey:GAMERESULTDATAKEY];
        }
    }
    return self;
}

+(NSArray *)getDictionaryOfGameResult{
    return [[GameResultData shareInstance] mutableArrayGameResult];
}

+(BOOL)setGameResultForDifLevel:(GameDifficultyLevel)difLevel bestPoints:(int)bestPoints isPerfectPlay:(BOOL)isPerfectPlay{
    
    BOOL isUpdateBestPoints = NO;
    NSDictionary *dicDifLevel = [[[GameResultData shareInstance] mutableArrayGameResult] objectAtIndex:difLevel];
    
    int bestPointsOld = [[dicDifLevel objectForKey:GAMEBESTPOINTKEY] intValue];
    if (bestPoints - bestPointsOld > 0) {
        [dicDifLevel setValue:[NSString stringWithFormat:@"%d",bestPoints] forKey:GAMEBESTPOINTKEY];
        isUpdateBestPoints = YES;
    }
    
    int perfectTimesOld = [[dicDifLevel objectForKey:GAMEPEFECTTIMESKET] intValue];
    [dicDifLevel setValue:[NSString stringWithFormat:@"%d",perfectTimesOld+isPerfectPlay] forKey:GAMEPEFECTTIMESKET];
    
    return isUpdateBestPoints;
}

+(int)getBestPointsForDifLevel:(GameDifficultyLevel)difLevel{
    NSDictionary *dicDifLevel = [[[GameResultData shareInstance] mutableArrayGameResult] objectAtIndex:difLevel];
    int bestPoints = [[dicDifLevel objectForKey:GAMEBESTPOINTKEY] intValue];
    return bestPoints;
}

+(int)getPerfectTimesForDifLevel:(GameDifficultyLevel)difLevel{
    NSDictionary *dicDifLevel = [[[GameResultData shareInstance] mutableArrayGameResult] objectAtIndex:difLevel];
    int perfectTimes = [[dicDifLevel objectForKey:GAMEPEFECTTIMESKET] intValue];
    return perfectTimes;
}
@end
