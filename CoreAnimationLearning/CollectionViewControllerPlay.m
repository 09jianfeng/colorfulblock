//
//  CollectionViewControllerPlay.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/24.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "CollectionViewControllerPlay.h"
#import <AVFoundation/AVFoundation.h>
#import "GameAlgorithm.h"
#import "SpriteUIView.h"
#import "ProGressView.h"
#import "SystemInfo.h"
#import "LevelAndUserInfo.h"
#import "UIViewFinishPlayAlert.h"
#import "GameResultData.h"

NSString *playingViewExitNotification = @"playingViewExitNotification";

@interface CollectionViewControllerPlay ()<UIAlertViewDelegate>
{
   int seconde;
}

@property(nonatomic, retain) AVAudioPlayer *audioplayerCorrect;
@property(nonatomic, retain) AVAudioPlayer *audioplayerError;
@property(nonatomic, retain) GameAlgorithm *gameAlgorithm;
@property(nonatomic, retain) UIDynamicAnimator *animator;
@property(nonatomic, retain) UIGravityBehavior *gravity;
@property(nonatomic, retain) ProGressView *processView;
@property(nonatomic, retain) NSTimer *timer;
@property(nonatomic, retain) UILabel *labelPoints;
@property(nonatomic, assign) int Allpoints;
//mutArraySprites 存储正在动的sprites
@property(nonatomic, strong) NSMutableArray *mutArraySprites;
@end

@implementation CollectionViewControllerPlay

static NSString * const reuseIdentifier = @"Cell";

-(id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.widthNum = 11.0;
        self.timeLimit = 50;
        self.gameInitTypeNum = 3.0;
    }
    return self;
}

-(void)dealloc{
    self.mutArraySprites = nil;
    self.audioplayerCorrect = nil;
    self.audioplayerError = nil;
    self.gameAlgorithm = nil;
    self.animator = nil;
    self.gravity = nil;
    self.processView = nil;
    self.timer = nil;
    self.labelPoints = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *backImage = [UIImage imageNamed:@"playing_background"];
    self.collectionView.layer.contents = (__bridge id)(backImage.CGImage);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    seconde = 0;
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.delegate = self;
    self.collectionView.scrollEnabled = NO;
    // Do any additional setup after loading the view.
    
    int processHeight = 20;
    //如果是ipad 横向右13.0个方块
    if (IsPadUIBlockGame()) {
        _widthNum +=2;
        processHeight = 40;
    }
    
    
    CGFloat width = self.view.frame.size.width/_widthNum;
    int heightnum = self.view.frame.size.height/width-1;
    
    float allblockNump = 0.65;
    self.gameAlgorithm = [[GameAlgorithm alloc] initWithWidthNum:_widthNum heightNum:heightnum gamecolorexternNum:self.gameInitTypeNum allblockNumpercent:allblockNump];
    
    //做重力动画的
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    //只能有一个重力系统
    self.gravity = [[UIGravityBehavior alloc] init];
    self.gravity.magnitude = 2;
    [self.animator addBehavior:self.gravity];
    
    self.labelPoints = [[UILabel alloc] init];
    self.labelPoints.frame = CGRectMake(self.view.frame.size.width - 50,self.view.frame.size.height - processHeight, 50, 20);
    self.labelPoints.text = @"0";
    self.labelPoints.font = [UIFont systemFontOfSize:18];
    self.labelPoints.textAlignment = NSTextAlignmentCenter;
    self.labelPoints.textColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:1.0];
    if (!_noBackgroundImage) {
        [self.view addSubview:self.labelPoints];
    }
    
    UIButton *buttonStop = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    buttonStop.frame = CGRectMake(self.view.frame.size.width - 100,self.view.frame.size.height - processHeight, 50, 20);
    [buttonStop addTarget:self action:@selector(buttonStopPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonStop];
    
    int labelLen = 180;
    if (IsPadUIBlockGame()) {
        labelLen = 620;
    }
    self.processView = [[ProGressView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - processHeight+10, labelLen, 5)];
    self.processView.backgroundColor = [UIColor whiteColor];
    self.processView.alpha = 0.5;
    if (!_noBackgroundImage) {
        [self.view addSubview:self.processView];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerResponce:) userInfo:nil repeats:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark 事件
-(void)timerResponce:(id)sender{
    seconde++;
    [self.processView setprocess:seconde/_timeLimit];
    
    if (seconde > _timeLimit) {
        [self endTheGame];
    }
}

-(void)buttonStopPressed:(id)sender{
    [self.timer invalidate];
    UIViewFinishPlayAlert *finish = [[UIViewFinishPlayAlert alloc] initWithFrame:self.view.bounds];
    finish.tag = 3000;
    [self.view addSubview:finish];
    finish.collectionViewController = self;
    [finish showView];
}

#pragma mark -
#pragma mark logic
-(void)endTheGame{
    [self.timer invalidate];
    NSString *message = @"";
    [GameResultData gameResultAddBrockenBlocks:self.Allpoints];
    if (self.Allpoints >= [_gameAlgorithm getAllValueBlockNum]) {
        [LevelAndUserInfo passLevel:_gameLevelIndex points:_Allpoints startNum:3];
        message = [NSString stringWithFormat:@"恭喜过关\n您的总分是：%d",self.Allpoints];
    }else{
        message = [NSString stringWithFormat:@"很遗憾\n您的总分是：%d",self.Allpoints];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"重玩",nil];
    [alert show];
}

-(void)replayGame{
    self.Allpoints = 0;
    [self.processView setprocess:0.0];
    seconde = 0;
    CGFloat width = self.view.frame.size.width/_widthNum;
    int heightnum = self.view.frame.size.height/width - 1;
    self.gameAlgorithm = [[GameAlgorithm alloc] initWithWidthNum:_widthNum heightNum:heightnum gamecolorexternNum:self.gameInitTypeNum allblockNumpercent:0.65];
    [self.collectionView reloadData];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerResponce:) userInfo:nil repeats:YES];
}

-(void)playAudioIsCorrect:(BOOL)isCorrect{
    NSString *stringCottect = @"";
    if (isCorrect) {
        stringCottect = @"correct.mp3";
    }else{
        stringCottect = @"error.mp3";
    }
    //1.音频文件的url路径
    NSURL *url=[[NSBundle mainBundle]URLForResource:stringCottect withExtension:Nil];
    //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
    self.audioplayerCorrect=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
    //3.缓冲
    [self.audioplayerCorrect prepareToPlay];
    [self.audioplayerCorrect play];
}

-(int)numberOfblock{
    CGFloat width = self.view.frame.size.width/_widthNum;
    int heightnum = self.view.frame.size.height/width + 1;
    return heightnum*_widthNum;
}

-(UIImage *)getColorInColorType:(blockcolor)blockcolorType{
    switch (blockcolorType) {
        case blockcolornone:
            return nil;
            break;
        case blockcolor1:
            return [UIImage imageNamed:@"1.png"];
            break;
        case blockcolor2:
            return [UIImage imageNamed:@"2.png"];
            break;
        case blockcolor3:
            return [UIImage imageNamed:@"3.png"];
            break;
        case blockcolor4:
            return [UIImage imageNamed:@"4.png"];
            break;
        
        case blockcolor5:
            return [UIImage imageNamed:@"5.png"];
            break;
        case blockcolor6:
            return [UIImage imageNamed:@"6.png"];
            break;
        case blockcolor7:
            return [UIImage imageNamed:@"7.png"];
            break;
        case blockcolor8:
            return [UIImage imageNamed:@"8.png"];
            break;
        case blockcolor9:
            return [UIImage imageNamed:@"9.png"];
            break;
        case blockcolor10:
            return [UIImage imageNamed:@"10.png"];
            break;
        case blockcolor11:
            return [UIImage imageNamed:@"11.png"];
            break;
        case blockcolor12:
            return [UIImage imageNamed:@"12.png"];
            break;

        default:
            return nil;
            break;
    }
    return nil;
}

//被拆的动画效果
-(void)beginActionAnimatorBehavior:(__weak NSMutableArray *)arraySprites{
    for(SpriteUIView *sprite in arraySprites){
        if (sprite.pushBehavior) {
            //正在执行动画，下一个
            continue;
        }
        
        //给个斜着向上的速度
        [sprite generateBehaviorAndAdd:self.animator];
        [self.gravity addItem:sprite];
    }
    
    __weak UIGravityBehavior *gravity = self.gravity;
    //当物体离开了屏幕范围要移除掉，以免占用cpu资源
    __weak UIDynamicAnimator *anim = self.animator;
    CGRect rect = self.view.bounds;
    self.gravity.action = ^{
        NSArray* items = [anim itemsInRect:rect];
        for(int i = 0;i < arraySprites.count;i++){
            SpriteUIView *sprite2 = [arraySprites objectAtIndex:i];
            if (NSNotFound == [items indexOfObject:sprite2] && [sprite2 superview]) {
                [sprite2 removeBehaviorWithAnimator:anim];
                [gravity removeItem:sprite2];
                [sprite2 removeFromSuperview];
                [sprite2 setTimeInvilade];
                [arraySprites removeObjectAtIndex:i];
                i--;
            }
        }
    };
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfblock];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (indexPath.row%2) {
        if (!_noBackgroundImage) {
            UIImage *imageBlack = [UIImage imageNamed:@"playing_cellbackground1"];
            cell.layer.contents = (__bridge id)(imageBlack.CGImage);
        }
        
    }else{
        if (!_noBackgroundImage) {
            UIImage *imageBlack = [UIImage imageNamed:@"playing_cellbackground1"];
            cell.layer.contents = (__bridge id)(imageBlack.CGImage);
        }
    }
    
    //获取该块的颜色
    int colorType = [self.gameAlgorithm getColorInthisPlace:(int)indexPath.row];
    UIImage *color = [self getColorInColorType:colorType];
    SpriteUIView *sprite = (SpriteUIView *)[cell viewWithTag:1001];
    if (color) {
        if (!sprite) {
            sprite = [[SpriteUIView alloc] initWithFrame:CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height)];
            [cell addSubview:sprite];
            sprite.tag = 1001;
        }
        sprite.layer.contents = (__bridge id)(color.CGImage);
    }
    else if(sprite){
        [sprite removeFromSuperview];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = self.view.frame.size.width/_widthNum;
    return CGSizeMake(width, width);
}

//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//cell被选择时被调用
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3 animations:^{
        cell.alpha = 0.5;
    } completion:^(BOOL finish){
        cell.alpha = 1;
    }];
    [self playAudioIsCorrect:YES];
    
    NSMutableArray *mutableShoulUpdate = nil;
    //获取要remove掉的label
    NSArray *arrayshouldRemoveIndexpath = [self.gameAlgorithm getplacethatShoulddrop:(int)indexPath.row  placeShouldUpdate:&mutableShoulUpdate];
    //显示路径
    for (NSNumber *numIndex in mutableShoulUpdate) {
        int indexpathrow = [numIndex intValue];
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexpathrow inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
        UIView *pointsImageView = [[UIView alloc]initWithFrame:cell.bounds];
        pointsImageView.layer.contents = (__bridge id)([UIImage imageNamed:@"back_point.png"].CGImage);
        pointsImageView.alpha = 0.5;
        [cell addSubview:pointsImageView];
        [UIView animateWithDuration:0.3 animations:^{
            pointsImageView.alpha = 0.0;
        } completion:^(BOOL isfinish){
            [pointsImageView removeFromSuperview];
        }];
    }
    
    
    int spritesNumShouldDrop = 0;
    if (!self.mutArraySprites) {
        self.mutArraySprites = [[NSMutableArray alloc] init];
    }
    for (NSNumber *num in arrayshouldRemoveIndexpath) {
        int indexpathrow = [num intValue];
        NSIndexPath *path = [NSIndexPath indexPathForRow:indexpathrow inSection:0];
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
        SpriteUIView *sprite = (SpriteUIView *)[cell viewWithTag:1001];
        if (sprite) {
            spritesNumShouldDrop++;
            CGRect rect = [sprite convertRect:sprite.frame toView:self.view];
            [sprite removeFromSuperview];
            sprite.frame = rect;
            [self.view addSubview:sprite];
            [self.mutArraySprites addObject:sprite];
        }
    }
    [self beginActionAnimatorBehavior:self.mutArraySprites];
    
    _Allpoints = _Allpoints + spritesNumShouldDrop*2 - 2;
    self.labelPoints.text = [NSString stringWithFormat:@"%d",_Allpoints];
    
    [_gameAlgorithm isHaveBlockToDestroy:^(BOOL isHave){
        if (!isHave) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self endTheGame];
            });
        }
    }];
}

//cell反选时被调用(多选时才生效)
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}
#pragma mark -
#pragma mark alertviewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (alertView.tag == 2000) {
            [self continueGame];
        }else{
          [self replayGame];
        }
    }else if(buttonIndex == 0){
        [self exitTheGame];
    }
}

-(void)exitTheGame{
    [GameResultData gameResultAddBrockenBlocks:self.Allpoints];
    
//    UIView *alertView = [self.view viewWithTag:40000];
//    [UIView animateWithDuration:0.3 animations:^{
////        alertView.frame = CGRectMake(alertView.frame.origin.x, -self.view.frame.origin.y, alertView.frame.size.width, alertView.frame.size.height);
//    } completion:^(BOOL isFinish){
//        
//        [UIView animateWithDuration:0.3 animations:^{
//            self.view.frame = CGRectMake(self.view.frame.size.width*2, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
//        } completion:^(BOOL isFinish){
//            [self.view removeFromSuperview];
//            [self removeFromParentViewController];
//        }];
//        
//    }];
    
    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(self.view.frame.size.width*2, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        self.view.alpha = 0.0;
    } completion:^(BOOL isFinish){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:playingViewExitNotification object:nil userInfo:nil];
}

-(void)continueGame{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerResponce:) userInfo:nil repeats:YES];
}
@end
