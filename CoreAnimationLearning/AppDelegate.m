//
//  AppDelegate.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/19.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "AppDelegate.h"
#import "GAMADManager.h"
#import "GAMUMAnalyseManager.h"
#import "GameAudioPlay.h"
#import "AppDataStorage.h"
#import <BmobDataSDK/Bmob.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - 微信api相关
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([[AppDataStorage shareInstance] accessable]) {
        return YES;
    }
    
    // Override point for customization after application launch.
    BOOL isValid = [WXApi registerApp:weixinAppid];
    if (!isValid) {
        NSLog(@"微信registerApp 失败");
    }
    
    [GAMADManager showGDTSplashAD];
    [GAMUMAnalyseManager initialUMSDK];
    
    [Bmob registerWithAppKey:@"fb55d2e9eb65825f185b25a17f99194f"];
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    [GameAudioPlay stopMainAudio];
    [WXApi handleOpenURL:url delegate:[WeiXinShare shareInstance]];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [GameAudioPlay stopMainAudio];
    NSLog(@"sourceAPP-------------------- %@",sourceApplication);
    [WXApi handleOpenURL:url delegate:[WeiXinShare shareInstance]];
    return YES;
}
@end
