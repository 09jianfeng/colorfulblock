//
//  GAMADManager.h
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/5.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDTMobInterstitial.h"
#import "GDTSplashAd.h"


@interface GAMADManager : NSObject
+(id)shareInstance;

+(void)showGDTInterstitial;
+(void)showGDTSplashAD;

+(BOOL)isOurSelf;
@end
