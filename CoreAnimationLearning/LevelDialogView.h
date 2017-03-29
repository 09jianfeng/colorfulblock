//
//  LevelDialogView+UsingAnimation.h
//  BasicClassLibrary
//
//  Created by DoubleZ on 13-11-14.
//  Copyright (c) 2013年 陈建峰. All rights reserved.
//

//  一切全屏显示View的基类
// 这个类主要都是用
#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface LevelDialogView : UIView {
 @protected
    UIViewController            *_platformViewController;
    UIInterfaceOrientation              _orientation;
    BOOL                                _isShowing;
}   
@property(nonatomic, retain) ViewController *viewController;

@end
