//
//  GlobalSetting.h
//  AppAssistant
//
//  Created by 陈建峰 on 16/3/23.
//  Copyright © 2016年 DouJinSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalSetting : NSObject
+(id)shareInstance;
+(NSString *)getStringAtIndex:(int)index;
@end
