//
//  GameSetting.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/3.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "GameSetting.h"
#import "GameKeyValue.h"

static NSString *ISFIRSTTIMEINSTALLKEY = @"ISFIRSTTIMEINSTALLKEY";
static NSString *ISVOICEOPENKEY = @"ISVOICEOPENKEY";
@implementation GameSetting
+(NSString *)gameAppURLInAppStore{
    return @"http://www.baidu.com";
}

+(BOOL)gameIsFirstInstall{
    BOOL isFirstInstall = [[GameKeyValue objectForKey:ISFIRSTTIMEINSTALLKEY] boolValue];
    if (!isFirstInstall) {
        [GameKeyValue setObject:[NSNumber numberWithBool:isFirstInstall] forKey:ISFIRSTTIMEINSTALLKEY];
    }
    return isFirstInstall;
}


+(BOOL)gameIsVoiceOpen{
    BOOL isVoiceOpen = [[GameKeyValue objectForKey:ISVOICEOPENKEY] boolValue];
    return !isVoiceOpen;
}

+(void)setGameVoiceOpen:(BOOL)isOpen{
    [GameKeyValue setObject:[NSNumber numberWithBool:!isOpen] forKey:ISVOICEOPENKEY];
}
@end
