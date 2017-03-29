//
//  GameKeyValue.h
//  HuaiNanVideoSDK
//
//  Created by ENZO YANG on 13-3-5.
//  Copyright (c) 2013年 HuaiNanVideoSDK Mobile Co. Ltd. All rights reserved.
//
//  作用：和NSUserDefault功能相似，为了不让开发者轻易看到SDK保存了什么

#import <UIKit/UIKit.h>

// 只支持能够序列化的类型
@interface GameKeyValue : NSObject

+ (BOOL)existValueOfKey:(NSString *)key;

+ (id)objectForKey:(NSString *)key;
// 类型不对会返回空或者 0
+ (NSString *)stringForKey:(NSString *)key;
+ (NSArray *)arrayForKey:(NSString *)key;
+ (NSDictionary *)dictionaryForKey:(NSString *)key;
+ (CGFloat)floatForKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key;
+ (BOOL)boolForKey:(NSString *)key;

// 当setObject:nil forKey: 的时候不会改变原值
+ (void)setObject:(id)object forKey:(NSString *)key;
// 类型不对不会改变原值
+ (void)setString:(NSString *)string forKey:(NSString *)key;
+ (void)setArray:(NSArray *)array forKey:(NSString *)key;
+ (void)setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;
+ (void)setFloat:(CGFloat)number forKey:(NSString *)key;
+ (void)setIntegerForKey:(NSInteger)number forKey:(NSString *)key;
+ (void)setBoolForKey:(BOOL)number forKey:(NSString *)key;

+ (void)removeObjectForKey:(NSString *)key;
+ (void)synchronize;

@end
