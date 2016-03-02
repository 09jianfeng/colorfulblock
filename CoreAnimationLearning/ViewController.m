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
#import "RankingView.h"

extern NSString *playingViewExitNotification;

@interface ViewController (){
    float radius;
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
    [self addSubViews];
}

-(void)addSubViews{
    UIImage *manuBackground = [UIImage imageNamed:@"playing_background"];
    self.view.layer.contents = (__bridge id)(manuBackground.CGImage);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.tag = 10000;
    imageView.image = [UIImage imageNamed:@"image_title.png"];
    imageView.layer.cornerRadius = 10.0;
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
    
    //难度1
    UIButton *difficultyLevel1 = [[UIButton alloc] initWithFrame:CGRectZero];
    difficultyLevel1.tag = 10001;
    difficultyLevel1.backgroundColor = [UIColor clearColor];
    [difficultyLevel1 setImage:[UIImage imageNamed:@"btn_easy.png"] forState:UIControlStateNormal];
    [difficultyLevel1 addTarget:self action:@selector(level1ButtonPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:difficultyLevel1];
    
    //难度2
    UIButton *difficultyLevel2 = [[UIButton alloc] initWithFrame:CGRectZero];
    difficultyLevel2.tag = 10002;
    difficultyLevel2.backgroundColor = [UIColor clearColor];
    [difficultyLevel2 setImage:[UIImage imageNamed:@"btn_normal.png"] forState:UIControlStateNormal];
    [difficultyLevel2 addTarget:self action:@selector(level2ButtonPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:difficultyLevel2];
    
    //难度3
    UIButton *difficultyLevel3 = [[UIButton alloc] initWithFrame:CGRectZero];
    difficultyLevel3.tag = 10003;
    difficultyLevel3.backgroundColor = [UIColor clearColor];
    [difficultyLevel3 setImage:[UIImage imageNamed:@"btn_hard.png"] forState:UIControlStateNormal];
    [difficultyLevel3 addTarget:self action:@selector(level3ButtonPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:difficultyLevel3];
    
    //难度4
    UIButton *difficultyLevel4 = [[UIButton alloc] initWithFrame:CGRectZero];
    difficultyLevel4.tag = 10004;
    difficultyLevel4.backgroundColor = [UIColor clearColor];
    [difficultyLevel4 setImage:[UIImage imageNamed:@"btn_crazy.png"] forState:UIControlStateNormal];
    [difficultyLevel4 addTarget:self action:@selector(level4ButtonPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:difficultyLevel4];
    
    UIButton *buttonRanking = [[UIButton alloc] initWithFrame:CGRectZero];
    buttonRanking.tag = 10005;
    buttonRanking.backgroundColor = [UIColor clearColor];
    [buttonRanking setImage:[UIImage imageNamed:@"btn_rank"] forState:UIControlStateNormal];
    [buttonRanking addTarget:self action:@selector(buttonPressedRanking:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonRanking];
    
    UIButton *buttonShare = [[UIButton alloc] initWithFrame:CGRectZero];
    buttonShare.tag = 10006;
    buttonShare.backgroundColor = [UIColor clearColor];
    [buttonShare setImage:[UIImage imageNamed:@"btn_praise"] forState:UIControlStateNormal];
    [self.view addSubview:buttonShare];
    
    UIButton *buttonStar = [[UIButton alloc] initWithFrame:CGRectZero];
    buttonStar.tag = 10007;
    buttonStar.backgroundColor = [UIColor clearColor];
    [buttonStar setImage:[UIImage imageNamed:@"btn_share"] forState:UIControlStateNormal];
    [self.view addSubview:buttonStar];
    
    
    [self beginMainManuAnimation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingViewExitNotificationResponseControl:) name:playingViewExitNotification object:nil];
}


-(void)beginMainManuAnimation{
    
    int unitHeight = CGRectGetHeight(self.view.frame)/36;
    int buttonHeight = unitHeight*3;
    int buttonWidth = buttonHeight*2.6;
    int topOffset = -unitHeight*4;
    int buttonInsert = unitHeight;
    float animateTime = 0.5;
    
    UIImageView *imageView = [self.view viewWithTag:10000];
    imageView.frame = CGRectMake(self.view.frame.size.width/2.0-radius*5.5/2.5, -self.view.frame.size.height, radius*5.5, radius*3.5);
    [UIView animateWithDuration:animateTime animations:^{
        imageView.frame = CGRectMake(self.view.frame.size.width/2.0-radius*5.5/2.0, 50.0, radius*5.5, radius*3.5);
    }completion:^(BOOL finished) {
        [self beginAnimation:imageView];
    }];
    
    UIButton *difficultyLevel1 = [self.view viewWithTag:10001];
    difficultyLevel1.frame = CGRectMake(-self.view.frame.size.width, CGRectGetHeight(self.view.frame)/2 + topOffset, buttonWidth, buttonHeight);
    [UIView animateWithDuration:animateTime animations:^{
        difficultyLevel1.frame = CGRectMake(self.view.frame.size.width/2-buttonWidth/2, CGRectGetHeight(self.view.frame)/2 + topOffset, buttonWidth, buttonHeight);
    } completion:^(BOOL isFinish){
    }];
    
    UIButton *difficultyLevel2 = [self.view viewWithTag:10002];
    difficultyLevel2.frame = CGRectMake(2*self.view.frame.size.width, difficultyLevel1.frame.origin.y+difficultyLevel1.frame.size.height+buttonInsert, buttonWidth, buttonHeight);
    [UIView animateWithDuration:animateTime animations:^{
        difficultyLevel2.frame = CGRectMake(self.view.frame.size.width/2-buttonWidth/2, difficultyLevel1.frame.origin.y+buttonHeight+buttonInsert, buttonWidth, buttonHeight);
    } completion:^(BOOL isFinish){
    }];
    
    UIButton *difficultyLevel3 = [self.view viewWithTag:10003];
    difficultyLevel3.frame = CGRectMake(-self.view.frame.size.width, difficultyLevel2.frame.origin.y+buttonHeight+buttonInsert, buttonWidth, buttonHeight);
    [UIView animateWithDuration:animateTime animations:^{
        difficultyLevel3.frame = CGRectMake(self.view.frame.size.width/2-buttonWidth/2, difficultyLevel2.frame.origin.y+buttonHeight+buttonInsert, buttonWidth, buttonHeight);
    } completion:^(BOOL isFinish){
    }];
    
    UIButton *difficultyLevel4 = [self.view viewWithTag:10004];
    difficultyLevel4.frame = CGRectMake(2*self.view.frame.size.width, difficultyLevel3.frame.origin.y+buttonHeight+buttonInsert, buttonWidth, buttonHeight);
    [UIView animateWithDuration:animateTime animations:^{
        difficultyLevel4.frame = CGRectMake(self.view.frame.size.width/2-buttonWidth/2, difficultyLevel3.frame.origin.y+buttonHeight+buttonInsert, buttonWidth, buttonHeight);
    } completion:^(BOOL isFinish){
    }];
    
    
    
    int unitWidth = CGRectGetWidth(self.view.frame)/16;
    int leftOffset = unitWidth*3;
    int buttonFunctionWidth = unitWidth*2;
    int buttonFunctionY = CGRectGetHeight(self.view.frame) - buttonFunctionWidth * 2;
    
    UIButton *buttonRanking = [self.view viewWithTag:10005];
    buttonRanking.frame = CGRectMake(-leftOffset, buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth);
    [UIView animateWithDuration:1.0 animations:^{
        buttonRanking.frame = CGRectMake(leftOffset, buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth);
    } completion:^(BOOL finished) {
    }];
    
    UIButton *buttonShare = [self.view viewWithTag:10006];
    buttonShare.frame = CGRectMake(buttonRanking.frame.origin.x + buttonFunctionWidth*2, buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth);
    
    UIButton *buttonStar = [self.view viewWithTag:10007];
    buttonStar.frame = CGRectMake(self.view.frame.size.width, buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth);
    [UIView animateWithDuration:1.0 animations:^{
        buttonStar.frame = CGRectMake(buttonShare.frame.origin.x + buttonFunctionWidth*2, buttonFunctionY, buttonFunctionWidth, buttonFunctionWidth);
    } completion:^(BOOL finished) {
    }];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 开始拆砖块游戏
-(void)beginGameWith:(int)timeLimit widthNum:(int)widthNum colorNum:(int)colorNum gameDifficultyLevel:(GameDifficultyLevel)gameDifficultyLevel{
    //移除imageView的循环动画效果，以免影响正在做的游戏效果
    UIImageView *imageView = [self.view viewWithTag:10000];
    [imageView.layer removeAllAnimations];
    
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    CollectionViewControllerPlay *collecPlay = [[CollectionViewControllerPlay alloc] initWithCollectionViewLayout:flowlayout];
    collecPlay.view.backgroundColor = [UIColor whiteColor];
    collecPlay.collectionView.backgroundColor = [UIColor whiteColor];
    
    collecPlay.timeLimit = timeLimit;
    collecPlay.gameDifficultyLevel = gameDifficultyLevel;
    collecPlay.widthNum = widthNum;
    collecPlay.gameInitTypeNum = colorNum;
    
    [self addChildViewController:collecPlay];
    [self.view addSubview:collecPlay.view];
    collecPlay.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        collecPlay.view.alpha = 1.0;
    }];
}

#pragma mark -
#pragma mark button事件
-(void)playingViewExitNotificationResponseControl:(id)send{
    [self beginMainManuAnimation];
}

-(void)level1ButtonPlayPressed:(id)sender{
    [self beginGameWith:50 widthNum:8 colorNum:8 gameDifficultyLevel:GameDifficultyLevel1];
}

-(void)level2ButtonPlayPressed:(id)sender{
    [self beginGameWith:56 widthNum:9 colorNum:9 gameDifficultyLevel:GameDifficultyLevel2];
}

-(void)level3ButtonPlayPressed:(id)sender{
    [self beginGameWith:60 widthNum:10 colorNum:10 gameDifficultyLevel:GameDifficultyLevel3];
}

-(void)level4ButtonPlayPressed:(id)sender{
    [self beginGameWith:60 widthNum:11 colorNum:12 gameDifficultyLevel:GameDifficultyLevel4];
}

-(void)buttonPressedRanking:(id)sender{
    RankingView *rankingView = [[RankingView alloc] initWithFrame:self.view.bounds];
    rankingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [rankingView showView];
    [self.view addSubview:rankingView];
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
#pragma mark 动画
//左右摇动变大变小的动画
-(void)beginAnimation:(UIView *)bt{
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
    scaleX.values = @[@1.0,@1.02,@1.0];
    scaleX.keyTimes = @[@0.0,@0.5,@1.0];
    scaleX.repeatCount = MAXFLOAT;
    scaleX.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    float randNumx = (arc4random()%5 + 20)/10.0;
    scaleX.duration = randNumx;
    
    //y方向伸缩
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.values = @[@1.0,@1.02,@1.0];
    scaleY.keyTimes = @[@0.0,@0.5,@1.0];
    scaleY.repeatCount = MAXFLOAT;
    scaleY.autoreverses = YES;
    scaleY.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    float randNumy = (arc4random()%5 + 20)/10.0;
    scaleY.duration = randNumy;
    
    CAAnimationGroup *groupAnnimation = [CAAnimationGroup animation];
    groupAnnimation.autoreverses = YES;
    groupAnnimation.duration = (arc4random()%30 + 30)/10.0;
    groupAnnimation.animations = @[pathAnimation,scaleX, scaleY];
    groupAnnimation.repeatCount = MAXFLOAT;
    //开演
    [bt.layer addAnimation:groupAnnimation forKey:@"groupAnnimation"];
}
@end
