//
//  LevelAndUserInfo.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/5/4.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelAndUserInfo : NSObject
@property(nonatomic,retain) NSMutableArray *arrayLevelInfos;
+(id)shareInstance;

//每一关需要的时间
+(NSArray *)levelInfos;
//通过这关
+(void)passLevel:(int)levelIndex points:(int)points startNum:(int)startNum;
//0 没有通过，1、2、3分别表示几颗星.如果通过则写入文件
+(int)isPassLevel:(int)levelIndex;

//返回剩余的体力值
+(int)getRestEnergy;
//增加体力
+(void)addEnergy:(int)energy;
//减少体力值
+(void)reduceEnergy:(int)energy;
@end
