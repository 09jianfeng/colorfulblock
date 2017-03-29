//
//  SystemInfo.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/27.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SystemInfo : NSObject
BOOL IsPadUIBlockGame();
//加模糊效果，image是图片，blur是模糊度
UIImage *blurryImage(UIImage *image,CGFloat blur);
@end
