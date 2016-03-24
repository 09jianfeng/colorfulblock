//
//  GlobalSetting.m
//  AppAssistant
//
//  Created by 陈建峰 on 16/3/23.
//  Copyright © 2016年 DouJinSDK. All rights reserved.
//

#import "GlobalSetting.h"
#import "CocoaSecurity.h"

@interface GlobalSetting()
@property(nonatomic, retain) NSArray *arrayConstantString;
@end

@implementation GlobalSetting
+(id)shareInstance{
    static GlobalSetting *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GlobalSetting new];
    });
    return instance;
}

-(id)init{
    self = [super init];
    if (self) {
        NSString *filePath = [[NSBundle mainBundle] resourcePath];
        filePath = [filePath stringByAppendingFormat:@"/btn_feedback.png"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSString *dataString = aesDecrypt(data);
        self.arrayConstantString = [NSPropertyListSerialization propertyListWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] options:NSPropertyListReadCorruptError format:nil error:nil];
    }
    return self;
}

// 这里获取的String 对应着文件 arrayString.plist里面的字符串
+(NSString *)getStringAtIndex:(int)index{
    return [[[GlobalSetting shareInstance] arrayConstantString] objectAtIndex:index];
}

@end
