//
//  IntroduceView.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/3.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "IntroduceView.h"
#import <UIKit/UIKit.h>
#import "GameAudioPlay.h"

@implementation IntroduceView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        float multi = [UIScreen mainScreen].bounds.size.height / [UIScreen mainScreen].bounds.size.width;
        NSString *imageFileName = @"introduce_5s";
        if (multi < 1.77) {
            imageFileName = @"introduce_4s";
        }
        NSString *filePath = [[NSBundle mainBundle] pathForResource:imageFileName ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        self.image = image;
        self.userInteractionEnabled = YES;
        
        float buttonBackWidth = 30;
        float buttonBackHeigh = 30;
        UIButton *buttonBack = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame)/2.0 - buttonBackWidth/2.0, CGRectGetHeight(frame) - buttonBackHeigh*1.5, buttonBackWidth, buttonBackHeigh)];
        [buttonBack setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
        [buttonBack addTarget:self action:@selector(buttonPressedIntroducBack:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonBack];
    }
    return self;
}

-(void)buttonPressedIntroducBack:(id)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, -CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    [GameAudioPlay playViewSwitchAudio];
}

@end
