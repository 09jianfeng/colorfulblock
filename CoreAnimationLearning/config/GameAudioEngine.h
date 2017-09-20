//
//  GameAudioEngine.h
//  storyBoardBook
//
//  Created by 陈建峰 on 16/7/22.
//  Copyright © 2016年 陈建峰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameAudioEngine : UITableView

+ (instancetype)shareInstance;

- (BOOL)accEncode;
- (NSString *)accDecode;

- (void)processAudioData;
@end
