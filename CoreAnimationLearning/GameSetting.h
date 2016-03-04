//
//  GameSetting.h
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/3.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameSetting : NSObject
+(NSString *)gameAppURLInAppStore;

+(BOOL)gameIsFirstInstall;

+(BOOL)gameIsVoiceOpen;
+(void)setGameVoiceOpen:(BOOL)isOpen;
@end
