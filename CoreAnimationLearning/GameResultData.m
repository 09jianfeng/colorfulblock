//
//  GameResultData.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/5/31.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "GameResultData.h"
#import "GameKeyValue.h"

static NSString *GAMERESULTDATAKEY = @"GAMERESULTDATAKEY";
static NSString *GAMEBESTPOINTKEY = @"GAMEBESTPOINTKEY";
static NSString *GAMEPEFECTTIMESKET = @"GAMEPEFECTTIMESKET";

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

+(void)setGameResultForDifLevel:(GameDifficultyLevel)difLevel bestPoints:(int)bestPoints isPerfectPlay:(BOOL)isPerfectPlay{
    NSDictionary *dicDifLevel = [[[GameResultData shareInstance] mutableArrayGameResult] objectAtIndex:difLevel-1];
    
    int bestPointsOld = [[dicDifLevel objectForKey:GAMEBESTPOINTKEY] intValue];
    if (bestPoints - bestPointsOld > 0) {
        [dicDifLevel setValue:[NSString stringWithFormat:@"%d",bestPoints] forKey:GAMEBESTPOINTKEY];
    }
    
    int perfectTimesOld = [[dicDifLevel objectForKey:GAMEPEFECTTIMESKET] intValue];
    [dicDifLevel setValue:[NSString stringWithFormat:@"%d",perfectTimesOld+isPerfectPlay] forKey:GAMEPEFECTTIMESKET];
}

+(int)getBestPointsForDifLevel:(GameDifficultyLevel)difLevel{
    NSDictionary *dicDifLevel = [[[GameResultData shareInstance] mutableArrayGameResult] objectAtIndex:difLevel-1];
    int bestPoints = [[dicDifLevel objectForKey:GAMEBESTPOINTKEY] intValue];
    return bestPoints;
}

+(int)getPerfectTimesForDifLevel:(GameDifficultyLevel)difLevel{
    NSDictionary *dicDifLevel = [[[GameResultData shareInstance] mutableArrayGameResult] objectAtIndex:difLevel-1];
    int perfectTimes = [[dicDifLevel objectForKey:GAMEPEFECTTIMESKET] intValue];
    return perfectTimes;
}
@end
