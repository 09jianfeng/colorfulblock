//
//  GAMUMAnalyseManager.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/5.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "GAMUMAnalyseManager.h"

static NSString *UMANALYSEAPPKEY = @"56da441ae0f55a278d0016b6";

@implementation GAMUMAnalyseManager
+(void)initialUMSDK{
    [MobClick setLogEnabled:YES];
    [MobClick startWithAppkey:UMANALYSEAPPKEY];
}
@end
