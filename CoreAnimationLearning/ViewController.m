//
//  ViewController.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/19.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewControllerPlay.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import "BallView.h"
#import "LevelDialogView.h"
#import "SystemInfo.h"
#import "GameResultData.h"

extern NSString *playingViewExitNotification;

@interface ViewController (){
    float radius;
    float circleX;
    float circleY;
    int ballNumber;
}

@property(nonatomic, retain) UIDynamicAnimator *theAnimator;
@property(nonatomic, retain) UIGravityBehavior *gravityBehaviour;
@property(nonatomic, retain) NSArray *backgroundArray;
@property(nonatomic, retain) NSMutableArray *arrayButtons;

@property(nonatomic, assign) int circleNum;
@property(nonatomic, assign) int beginCircleNum;
@end

@implementation ViewController
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:playingViewExitNotification object:nil];
    [self.theAnimator removeAllBehaviors];
    self.theAnimator = nil;
    self.gravityBehaviour = nil;
    self.backgroundArray = nil;
    self.arrayButtons = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayButtons = [[NSMutableArray alloc] initWithCapacity:6];
    radius = self.view.frame.size.width/8.0;
    //圆的x，y
    circleX = self.view.frame.size.width/2 - radius;
    circleY = self.view.frame.size.height - radius*10;
    [self addSubViews];
}

-(void)addSubViews{
    UIImage *manuBackground = [UIImage imageNamed:@"playing_background"];
    self.view.layer.contents = (__bridge id)(manuBackground.CGImage);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-radius*7/2, 50, radius*7, radius*3)];
    imageView.image = [UIImage imageNamed:@"image_title.png"];
    imageView.layer.cornerRadius = 10.0;
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    
    //开始游戏按钮
    UIButton *beginPlayButton = [[UIButton alloc] initWithFrame:CGRectMake(-self.view.frame.size.width, imageView.frame.origin.y+imageView.frame.size.height+radius, radius*4, radius*1.5)];
    [beginPlayButton setImage:[UIImage imageNamed:@"image_begin.png"] forState:UIControlStateNormal];
    beginPlayButton.backgroundColor = [UIColor clearColor];
    [beginPlayButton addTarget:self action:@selector(buttonPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageView];
    [self.view addSubview:beginPlayButton];
    [UIView animateWithDuration:1.0 animations:^{
        beginPlayButton.frame = CGRectMake(self.view.frame.size.width/2-radius*2, imageView.frame.origin.y+imageView.frame.size.height+radius, radius*4, radius*1.5);
    } completion:^(BOOL isFinish){
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingViewExitNotificationResponseControl:) name:playingViewExitNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 事件
-(void)playingViewExitNotificationResponseControl:(id)send{
    UILabel *allPointsShowView = (UILabel *)[self.view viewWithTag:1103];
    int numbers = [GameResultData getAllBlockenBlocks];
    if(allPointsShowView)
    allPointsShowView.text = [NSString stringWithFormat:@"您共拆了%d砖块",numbers];
}

-(void)buttonPlayPressed:(id)sender{
    LevelDialogView *levelDialogView = [[LevelDialogView alloc] initWithFrame:self.view.bounds];
    levelDialogView.viewController = self;
    levelDialogView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:levelDialogView];
}

#pragma mark -
#pragma mark 一直循环执行的动画效果
-(void)alwaysMove:(UIView *)view timeInterval:(int)timeInterval{
    [UIView animateWithDuration:timeInterval animations:^{
        view.frame = CGRectMake(-view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    } completion:^(BOOL isFinish){
        view.frame = CGRectMake(self.view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        [self alwaysMove:view timeInterval:timeInterval];
    }];
}

#pragma mark -
#pragma mark 球的吸附效果
-(void)initAnimatorAndGravity{
    if (!self.theAnimator) {
        self.theAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    if (!self.gravityBehaviour) {
     self.gravityBehaviour = [[UIGravityBehavior alloc] init];
    }
    self.gravityBehaviour.gravityDirection = CGVectorMake(0, -1);
    ViewController *controller = self;
    //球的吸附效果
    NSArray *arrayViews = self.arrayButtons;
    [self.gravityBehaviour setAction:^{
        for (UIView *ballView in arrayViews) {
            if (ballView.frame.origin.y <= circleY + radius*4) {
                UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:ballView
                                                                        snapToPoint:CGPointMake([controller getPositionXFor:(ballView.tag-1000) * M_PI / 3], [controller getPositionYFor:(ballView.tag-1000) * M_PI / 3])];
                [snapBehavior setAction:^{
                    
                }];
                [controller.theAnimator addBehavior:snapBehavior];
            }
            
        }
    }];
    [self.theAnimator addBehavior:self.gravityBehaviour];
}

- (double)getPositionYFor:(double)radian {
    int y = circleY + radius + radius * sin(radian);
    return y;
}

- (double)getPositionXFor:(double)radian {
    double x = circleX + radius + radius * cos(radian);
    return x;
}


#pragma mark -
#pragma mark 动画
//左右摇动变大变小的动画
-(void)beginAnimation:(UIButton *)bt{
    //1.绕中心圆移动 Circle move   没添加进去先
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = false;
    pathAnimation.repeatCount = MAXFLOAT;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(bt.frame, bt.frame.size.width/2-3, bt.frame.size.width/2-3);
    CGPathAddEllipseInRect(curvedPath, nil, circleContainer);
    pathAnimation.path = curvedPath;
    float randNumP = (arc4random()%5 + 20)/10.0;
    pathAnimation.duration = randNumP;
    
    //x方向伸缩
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleX.values = @[@1.0,@1.1,@1.0];
    scaleX.keyTimes = @[@0.0,@0.5,@1.0];
    scaleX.repeatCount = MAXFLOAT;
    scaleX.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    float randNumx = (arc4random()%5 + 20)/10.0;
    scaleX.duration = randNumx;
    
    //y方向伸缩
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.values = @[@1.0,@1.1,@1.0];
    scaleY.keyTimes = @[@0.0,@0.5,@1.0];
    scaleY.repeatCount = MAXFLOAT;
    scaleY.autoreverses = YES;
    scaleY.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    float randNumy = (arc4random()%5 + 20)/10.0;
    scaleY.duration = randNumy;
    
    CAAnimationGroup *groupAnnimation = [CAAnimationGroup animation];
    groupAnnimation.autoreverses = YES;
    groupAnnimation.duration = (arc4random()%30 + 30)/10.0;
    groupAnnimation.animations = @[scaleX, scaleY];
    groupAnnimation.repeatCount = MAXFLOAT;
    //开演
    [bt.layer addAnimation:groupAnnimation forKey:@"groupAnnimation"];
}
@end
