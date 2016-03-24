//
//  AASMacro.h
//  AASitSDK
//
//  Created by ENZO YANG on 13-2-21.
//  Copyright (c) 2013年 AASit Mobile Co. Ltd. All rights reserved.
//
//  宏定义，用于Log输出，以及其它

#import "GlobalSetting.h"

#ifndef AASConstantStringGet
#define AASConstantStringGet(xx) [GlobalSetting getStringAtIndex:xx]
#endif

#ifndef XOR_KEY
#define XOR_KEY 0x11
#endif

#ifndef AASitSDK_AASMacro_h
#define AASitSDK_AASMacro_h

#ifndef ConfuseInsertCode
#define ConfuseInsertCode int a=5;int b=6;a^=b;b^=a;a^=b;
#endif

//*** begin Debug Utils

// 只有我的手机和测试设备才显示日志.
// 无论什么情况， 错误都打印出来
#ifdef DEBUG
#define AASOG_RELEASE(xx, ...) NSLog(@"<RE>: " xx, ##__VA_ARGS__)
#else
#define AASOG_RELEASE(xx, ...)  ((void)0)
#endif


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LETTER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define FIX_EDGES_FOR_EXTENDEDLAYTOU if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) \
{ \
self.edgesForExtendedLayout = UIRectEdgeNone;\
} \

// 无论什么情况， 错误都打印出来
#ifdef DEBUG
#define AASOGERROR(xx, ...) NSLog(@"<ERROR> * %s(%d) *: " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
// 非DEBUG模式下不显示函数和行数
#define AASOGERROR(xx, ...) NSLog(@"<ERROR>: " xx, ##__VA_ARGS__)
#endif

#define SHOULD_PRINT_INFO 1
// 只有在DEBUG而且设置可以显示INFO的时候才显示INFO
#if defined(DEBUG) && defined(SHOULD_PRINT_INFO)
#define AASOGINFO(xx, ...) NSLog(@"<INFO>: " xx, ##__VA_ARGS__)
#else
#define AASOGINFO(xx, ...) ((void)0)
#endif

// URL用单独一个Log输出，便于复制，打印级别和INFO的一样
#if defined(DEBUG) && defined(SHOULD_PRINT_INFO)
#define AASOGURL(xx) NSLog(@"%@", xx)
#else
#define AASOGURL(xx) ((void)0)
#endif

#ifdef DEBUG
#define AASOGWARN(xx, ...) NSLog(@"<WARN>: " xx, ##__VA_ARGS__)
#else
#define AASOGWARN(xx, ...) ((void)0)
#endif

//*** end Debug Utils

//***为兼容之前(懒改), 下面不使用AAS前缀, 而是仍然使用YM前缀
// 对象销毁
#define YM_RELEASE_SAFELY(__POINTER) { __POINTER = nil; }//{ [__POINTER release]; __POINTER = nil; }
#define YM_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define YM_INVALIDATE_RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; [__TIMER release]; __TIMER = nil; }

// 字符串赋值
#define YM_ASSIGN_STRING_SAFELY(__VALUE) (((__VALUE) == nil) ? @"" : (__VALUE))
// 
#define YM_STRING_IS_NOT_VOID(__VALUE) (((__VALUE) != nil) && (![(__VALUE) isEqualToString:@""]))

// ***

// 角度转弧度
#define YM_RADIANS(DEGREES) (DEGREES * M_PI/180)
// 颜色
#define YM_UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])


#endif
