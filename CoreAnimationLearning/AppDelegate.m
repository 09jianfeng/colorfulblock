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
#import "PublicCallFunction.h"
#import "GameAudioPlay.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - 微信api相关
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [PublicCallFunction sharedInstance];
    if (getNeedStartMiLu()) {
        return YES;
    }
    
    BOOL isValid = [WXApi registerApp:weixinAppid];
    if (!isValid) {
        NSLog(@"微信registerApp 失败");
    }
    
    [GAMADManager showGDTSplashAD];
    [GAMUMAnalyseManager initialUMSDK];
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    [GameAudioPlay stopMainAudio];
    [WXApi handleOpenURL:url delegate:[WeiXinShare shareInstance]];
    return [[PublicCallFunction sharedInstance] application:application handleOpenURL:url];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [GameAudioPlay stopMainAudio];
    NSLog(@"sourceAPP-------------------- %@",sourceApplication);
    [WXApi handleOpenURL:url delegate:[WeiXinShare shareInstance]];
    return [[PublicCallFunction sharedInstance] application:application sourceApplication:sourceApplication openURL:url];
    return YES;
}
@end
