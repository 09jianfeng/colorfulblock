//
//  UIViewFinishPlayAlert.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/5/27.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "UIViewFinishPlayAlert.h"
#import "GameAudioPlay.h"
#import "GameResultData.h"

@interface UIViewFinishPlayAlert()
@property(nonatomic,retain) UIDynamicAnimator *ani;
@property(nonatomic,retain) UIGravityBehavior *gravity;
@end

@implementation UIViewFinishPlayAlert
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.ani = [[UIDynamicAnimator alloc] init];
        self.gravity = [[UIGravityBehavior alloc] init];
        [self.ani addBehavior:self.gravity];
    }
    return self;
}

-(void)continueGame{
    
}

-(void)showView{
    [GameResultData setGameResultForDifLevel:self.collectionViewController.gameDifficultyLevel bestPoints:self.gameCurrentPoints isPerfectPlay:self.isPerfectPlay];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    float boardWidth =  self.frame.size.width*2.0/3.0;
    float boardHeigh = boardWidth*0.8;
    UIView *board = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2.0 - boardWidth/2.0, -400,boardWidth, boardHeigh)];
    board.tag = 20000;
    board.layer.cornerRadius = 10.0;
    board.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg_stop"].CGImage);
    
    float unitHeigh = CGRectGetHeight(board.frame)/7.0;
    float unitWidth = CGRectGetWidth(board.frame)/14.0;
    float buttonFunctionWidth = unitWidth*3.0;
    float buttonFunctionY = CGRectGetHeight(board.frame) - unitHeigh/2.0 -  buttonFunctionWidth;
    
    UIImageView *labelDifficultyLevel = [[UIImageView alloc] initWithFrame:CGRectMake(boardWidth/2.0 - unitHeigh*2.0, unitHeigh, unitHeigh*4.0, unitHeigh)];
    NSString *diffLev = [NSString stringWithFormat:@"pic_name_0%d",self.collectionViewController.gameDifficultyLevel];
    labelDifficultyLevel.image = [UIImage imageNamed:diffLev];
    [board addSubview:labelDifficultyLevel];

    UILabel *labelPoints = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeigh, boardWidth, unitHeigh)];
    labelPoints.textAlignment = NSTextAlignmentCenter;
    labelPoints.textColor = [UIColor colorWithRed:160.0/255.0 green:52.0/255.0 blue:15.0/255.0 alpha:1.0];
    labelPoints.font = [UIFont fontWithName:@"AmericanTypewriter-bold" size:30.0];
    labelPoints.text = [NSString stringWithFormat:@"0"];
    labelPoints.center = CGPointMake(boardWidth/2, boardHeigh/2);
    [board addSubview:labelPoints];
    __block int points = 0;
    int gameCurrentPoints = self.gameCurrentPoints;
    //数字增加动画以及音效
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.04 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            [GameAudioPlay playNumAddingAudio];
            labelPoints.text = [NSString stringWithFormat:@"%d",points];
            points++;
            if (points >= gameCurrentPoints) {
                dispatch_source_cancel(timer);
            }
        });
        dispatch_resume(timer);
    });
    
    UIButton *buttonReplay = [[UIButton alloc] initWithFrame:CGRectMake(boardWidth/2 - buttonFunctionWidth/2, buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth)];
    buttonReplay.backgroundColor = [UIColor clearColor];
    [buttonReplay setImage:[UIImage imageNamed:@"button_reflesh"] forState:UIControlStateNormal];
    [buttonReplay addTarget:self action:@selector(buttonReplayLevelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [board addSubview:buttonReplay];
    
    UIButton *buttonContinue = [[UIButton alloc] initWithFrame:CGRectMake(boardWidth/2 - buttonFunctionWidth/2 - buttonFunctionWidth, buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth)];
    buttonContinue.backgroundColor = [UIColor clearColor];
    [buttonContinue setImage:[UIImage imageNamed:@"button_continue"] forState:UIControlStateNormal];
    [buttonContinue addTarget:self action:@selector(buttonContinuePressed:) forControlEvents:UIControlEventTouchUpInside];
    [board addSubview:buttonContinue];
    
    UIButton *buttonMainManu = [[UIButton alloc] initWithFrame:CGRectMake(boardWidth/2 + buttonFunctionWidth/2 , buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth)];
    buttonMainManu.backgroundColor = [UIColor clearColor];
    [buttonMainManu setImage:[UIImage imageNamed:@"button_home"] forState:UIControlStateNormal];
    [buttonMainManu addTarget:self action:@selector(buttonMainManu:) forControlEvents:UIControlEventTouchUpInside];
    [board addSubview:buttonMainManu];


    
    [self.gravity addItem:board];
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:board attachedToAnchor:CGPointMake(CGRectGetWidth(self.frame)/2, self.frame.size.height/2)];
    [attachmentBehavior setLength:0];
    [attachmentBehavior setDamping:0.3];
    [attachmentBehavior setFrequency:3];
    [self.ani addBehavior:attachmentBehavior];
    [self addSubview:board];
    
    //添加粒子效果,往下掉
    // 设置粒子发射的地方
    CAEmitterLayer *snowEmitter = [CAEmitterLayer layer];
    snowEmitter.emitterPosition = CGPointMake(self.bounds.size.width / 2.0,  -50);
    snowEmitter.emitterSize		= CGSizeMake(self.frame.size.width/2, self.frame.size.height/2);
    
    // Make the flakes seem inset in the background
    snowEmitter.shadowOpacity = 1.0;
    snowEmitter.shadowRadius  = 0.0;
    snowEmitter.shadowOffset  = CGSizeMake(0.0, 1.0);
    snowEmitter.shadowColor   = [[UIColor whiteColor] CGColor];
    // Spawn points for the flakes are within on the outline of the line
    snowEmitter.emitterMode		= kCAEmitterLayerSurface;
    snowEmitter.emitterShape	= kCAEmitterLayerLine;
    
    NSArray *emitterCells = [self getEmitters];
    // Add everything to our backing layer below the UIContol defined in the storyboard
    snowEmitter.emitterCells = emitterCells;
    [self.layer insertSublayer:snowEmitter atIndex:0];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [snowEmitter setValue:[NSNumber numberWithFloat:0.5] forKeyPath:@"emitterCells.snowflake.birthRate"];
    });
}

-(NSArray *)getEmitters{
    NSMutableArray *arrayEmitters = [[NSMutableArray alloc] initWithCapacity:12];
    for (int a = 0; a < 6; a++) {
        // Configure the snowflake emitter cell
        CAEmitterCell *snowflake = [CAEmitterCell emitterCell];
        
        snowflake.name = @"snowflake";
        snowflake.birthRate		= 1.0;
        snowflake.lifetime		= 1.0;
        snowflake.lifetimeRange = 2.0;
        
        snowflake.scale = 0.3;
        snowflake.velocity		= 200;				// 粒子速度
        snowflake.velocityRange = 100;
        snowflake.yAcceleration = 200;
        snowflake.emissionLongitude = 0;
        snowflake.emissionRange = 1 * M_PI;		// 周围发射角度
        snowflake.spinRange		= 0.25 * M_PI;		// 粒子旋转角度
        
        snowflake.contents		= (id) [[UIImage imageNamed:[NSString stringWithFormat:@"snow1.png"]] CGImage];
        snowflake.color			= [[UIColor colorWithRed:0.600 green:0.658 blue:0.743 alpha:1.000] CGColor];
        
        [arrayEmitters addObject:snowflake];
    }
    return arrayEmitters;
}

#pragma mark - 按钮事件
-(void)buttonContinuePressed:(id)sender{
    UIView *board = [self viewWithTag:20000];
    [self.ani removeAllBehaviors];
    [UIView animateWithDuration:0.5 animations:^{
        board.frame = CGRectMake(board.frame.origin.x, -self.frame.size.height, board.frame.size.width, board.frame.size.height);
    } completion:^(BOOL finished) {
        [self.collectionViewController contiuneTheGame];
        [self removeFromSuperview];
    }];
    
    [GameAudioPlay playViewSwitchAudio];
}

-(void)buttonReplayLevelPressed:(id)sender{
    UIView *board = [self viewWithTag:20000];
    [self.ani removeAllBehaviors];
    [UIView animateWithDuration:0.5 animations:^{
        board.frame = CGRectMake(board.frame.origin.x, -self.frame.size.height, board.frame.size.width, board.frame.size.height);
    } completion:^(BOOL finished) {
        [self.collectionViewController replayTheGame];
        [self removeFromSuperview];
    }];
    [GameAudioPlay playViewSwitchAudio];
}

-(void)buttonMainManu:(id)sender{
    [self.collectionViewController exitTheGame];
    [GameAudioPlay playViewSwitchAudio];
}

-(void)dealloc{
    self.ani = nil;
    self.gravity = nil;
}
@end
