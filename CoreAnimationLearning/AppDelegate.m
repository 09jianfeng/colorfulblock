//
//  AppDelegate.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/19.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "AppDelegate.h"
#import "GameCenterManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


#pragma mark - 微信api相关
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //    [XiaoZSinitialization sharedInstance];
    [WXApi registerApp:weixinAppid];
    [[GameCenterManager sharedManager] setupManager];
    //加密数据的秘钥，这个秘钥升级的时候不能变。否则会崩溃
    [[GameCenterManager sharedManager] setupManagerAndSetShouldCryptWithKey:@"3ufdekid"];
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
