//
//  GameKeyValue.h
//  HuaiNanVideoSDK
//
//  Created by ENZO YANG on 13-3-5.
//  Copyright (c) 2013年 HuaiNanVideoSDK Mobile Co. Ltd. All rights reserved.
//

#ifndef HNMacro_h
#define HNMacro_h

//混淆常量用的
#ifndef XOR_KEY
#define XOR_KEY 0xBB
#endif
extern void HNMixstring(unsigned char *str, unsigned char key);

//*** begin Debug Utils

// 无论什么情况， 错误都打印出来
#ifdef DEBUG
#define HNLOGERROR(xx, ...) NSLog(@"<ERROR> * %s(%d) *: " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
// 非DEBUG模式下不显示函数和行数
#define HNLOGERROR(xx, ...) NSLog(@"<ERROR>: " xx, ##__VA_ARGS__)
#endif

#define SHOULD_PRINT_INFO 1
// 只有在DEBUG而且设置可以显示INFO的时候才显示INFO
#if defined(DEBUG) && defined(SHOULD_PRINT_INFO)
#define HNLOGINFO(xx, ...) NSLog(@"<INFO>: " xx, ##__VA_ARGS__)
#else
#define HNLOGINFO(xx, ...) ((void)0)
#endif

// URL用单独一个Log输出，便于复制，打印级别和INFO的一样
#if defined(DEBUG) && defined(SHOULD_PRINT_INFO)
#define HNLOGURL(xx) NSLog(@"%@", xx)
#else
#define HNLOGURL(xx) ((void)0)
#endif

#ifdef DEBUG
#define HNLOGWARN(xx, ...) NSLog(@"<WARN>: " xx, ##__VA_ARGS__)
#else
#define HNLOGWARN(xx, ...) ((void)0)
#endif

//*** end Debug Utils
// 对象销毁
#define HN_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define HN_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }
#define HN_INVALIDATE_RELEASE_TIMER(__TIMER) { [__TIMER invalidate]; [__TIMER release]; __TIMER = nil; }

// 字符串赋值
#define HN_ASSIGN_STRING_SAFELY(__VALUE) (((__VALUE) == nil) ? @"" : (__VALUE))
//
#define HN_STRING_IS_NOT_VOID(__VALUE) (((__VALUE) != nil) && (![(__VALUE) isEqualToString:@""]))

// ***

// 角度转弧度
#define HN_RADIANS(DEGREES) (DEGREES * M_PI/180)
// 颜色
#define HN_UIColorFromRGB(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])


#endif