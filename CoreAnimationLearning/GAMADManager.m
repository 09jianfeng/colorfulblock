//
//  GAMADManager.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/5.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "GAMADManager.h"
#import "MobClick.h"
#import "GDTSplashAd.h"
#import "GDTMobInterstitial.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "GameKeyValue.h"

static NSString *GDTAPPID = @"1105153685";
static NSString *GDTMOBINTERSTITIALAPPKEY = @"4040801912471296";
static NSString *GDTSPLASHAPPKEY = @"4020907982979295";
static GAMADManager *_instance = nil;

@interface GAMADManager()<GDTMobInterstitialDelegate,GDTSplashAdDelegate>
@property(nonatomic, retain) GDTMobInterstitial *gdtInterstitial;
@end

@implementation GAMADManager
+(id)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[GAMADManager alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        [_instance initOnce];
    });
    return _instance;
}

- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return  _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone{
    return  _instance;
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

- (void)initOnce{
    //友盟统计
    [MobClick startWithAppkey:@"55bb39d367e58e305600131d"];
    //在线参数
    [MobClick updateOnlineConfig];
    
    //广点通插屏
    self.gdtInterstitial = [[GDTMobInterstitial alloc] initWithAppkey:GDTAPPID placementId:GDTMOBINTERSTITIALAPPKEY];
    self.gdtInterstitial.delegate = self;
    self.gdtInterstitial.isGpsOn = NO;
    [self.gdtInterstitial loadAd];
}

#pragma mark -
+(BOOL)isOurSelf{
    NSString *isOurselfNetWork = [GameKeyValue objectForKey:@"isOurSelfNetWork"];
    if (isOurselfNetWork) {
        NSLog(@"是自家网络，屏蔽广告，以免妨碍测试");
        return YES;
    }
    
    NSArray *ifs = (id)CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CFBridgingRelease(CNCopyCurrentNetworkInfo((CFStringRef)ifnam));
        if (info && [info count]) {
            break;
        }
    }
    
    if (info) {
        NSString *mi = @"mi";
        NSString *ssid = [info objectForKey:@"SSID"];
        NSRange range = [ssid rangeOfString:[NSString stringWithFormat:@"you%@",mi]];
        if (range.location != NSNotFound) {
            NSLog(@"是自家网络，屏蔽广告，以免妨碍测试");
            [GameKeyValue setObject:@"1" forKey:@"isOurSelfNetWork"];
            return YES;
        }
    }
    
    return NO;
}


+(void)showGDTInterstitial{
    if ([GAMADManager isOurSelf]) {
        return;
    }
    
    int randNum = arc4random()%3;
    if (!randNum) {
        UIViewController *vc = [[[UIApplication sharedApplication] keyWindow]
                                rootViewController];
        
        GDTMobInterstitial *_interstitialObj = [[GAMADManager shareInstance] gdtInterstitial];
        if (_interstitialObj.isReady) {
            NSLog(@"广点通 ready了");
            [_interstitialObj presentFromRootViewController:vc];
        }else{
            NSLog(@"广点通 还没ready");
            [_interstitialObj loadAd];
        }
    }
}

+(void)showGDTSplashAD{
    if ([GAMADManager isOurSelf]) {
        return;
    }
    
    //开屏广告初始化
    GDTSplashAd *_gdtSplash = [[GDTSplashAd alloc] initWithAppkey:GDTAPPID placementId:GDTSPLASHAPPKEY];
    _gdtSplash.delegate = [GAMADManager shareInstance];//设置代理
    //针对不同设备尺寸设置不同的默认图片，拉取广告等待时间会展示该默认图片。
    if ([[UIScreen mainScreen] bounds].size.height >= 568.0f) {
        _gdtSplash.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]];
    } else {
        _gdtSplash.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]];
    }
    
    UIWindow *fK = [[[UIApplication sharedApplication] delegate] window];
    //设置开屏拉取时长限制，若超时则不再展示广告
    _gdtSplash.fetchDelay = 10;
    //拉取并展示
    [_gdtSplash loadAdAndShowInWindow:fK];
}

#pragma mark - 广点通插屏代理
static NSString *INTERSTITIAL_STATE_TEXT = @"插屏状态";

/**
 *  广告预加载成功回调
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Success Loaded.");
}

/**
 *  广告预加载失败回调
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Fail Loaded." );
}

/**
 *  插屏广告将要展示回调
 *  详解: 插屏广告即将展示回调该函数
 */
- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Going to present.");
}

/**
 *  插屏广告视图展示成功回调
 *  详解: 插屏广告展示成功回调该函数
 */
- (void)interstitialDidPresentScreen:(GDTMobInterstitial *)interstitial
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Success Presented." );
}

/**
 *  插屏广告展示结束回调
 *  详解: 插屏广告展示结束回调该函数
 */
- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Finish Presented.");
    [_gdtInterstitial loadAd];
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Application enter background.");
}

/**
 *  插屏广告曝光时回调
 *  详解: 插屏广告曝光时回调
 */
-(void)interstitialWillExposure:(GDTMobInterstitial *)interstitial
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Exposured");
}
/**
 *  插屏广告点击时回调
 *  详解: 插屏广告点击时回调
 */
-(void)interstitialClicked:(GDTMobInterstitial *)interstitial
{
    NSLog(@"%@:%@",INTERSTITIAL_STATE_TEXT,@"Clicked");
}

#pragma mark - 广点通开屏代理
#pragma mark -
#pragma mark - 广点通开屏广告代理
-(void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error
{
    NSLog(@"%s%@",__FUNCTION__,error);
}

-(void)splashAdClicked:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdClosed:(GDTSplashAd *)splashAd
{
    NSLog(@"%s",__FUNCTION__);
}

-(void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd{
    NSLog(@"splashAdWillPresentFullScreen");
}

-(void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd{
    NSLog(@"splashADDidDismissFullScreenModal");
}

@end
