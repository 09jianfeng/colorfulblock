//
//  AppDelegate.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/19.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "AppDelegate.h"
#import "GameCenterManager.h"
#import "GAMADManager.h"
#import "GAMUMAnalyseManager.h"
#import "GAMGCManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - 微信api相关
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //    [XiaoZSinitialization sharedInstance];
    BOOL isValid = [WXApi registerApp:weixinAppid];
    if (!isValid) {
        NSLog(@"微信registerApp 失败");
    }
    
    [GAMGCManager initGameCenter];
    [GAMADManager showGDTSplashAD];
    [GAMUMAnalyseManager initialUMSDK];
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    [WXApi handleOpenURL:url delegate:[WeiXinShare shareInstance]];
    //    return [[XiaoZSinitialization sharedInstance] mll_application:application handleOpenURL:url];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    [WXApi handleOpenURL:url delegate:[WeiXinShare shareInstance]];
    //    return [[XiaoZSinitialization sharedInstance] mll_application:application openURL:url];
    return YES;
}
@end
