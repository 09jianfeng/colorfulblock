//
//  LevelDialogView+UsingAnimation.h
//  BasicClassLibrary
//
//  Created by DoubleZ on 13-11-14.
//  Copyright (c) 2013年 陈建峰. All rights reserved.
//

#import "LevelDialogView.h"
#import "CollectionViewCellLevel.h"
#import "CollectionViewControllerPlay.h"
#import "LevelAndUserInfo.h"

extern NSString *levelinfo;
extern NSString *levelinfoScore;
extern NSString *levelinfoTime;
extern NSString *levelinfoStarNum;
extern NSString *levelinfoWidthNum;
extern NSString *levelinfoColorNum;
extern NSString *playingViewExitNotification;

@interface LevelDialogView()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
@property(nonatomic, retain) UIDynamicAnimator *theAnimator;
@property(nonatomic, assign) int count;
@property(nonatomic, assign) int cellImageNum;
@property(nonatomic, assign) NSArray *arrayGuanka;
@end

@implementation LevelDialogView
- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initAndAddOtherSubview];
        _arrayGuanka = [[LevelAndUserInfo shareInstance] arrayLevelInfos];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingViewExitNotificationResponse:) name:playingViewExitNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:playingViewExitNotification object:nil];
    [self.theAnimator removeAllBehaviors];
    self.theAnimator = nil;
}

#pragma mark -
#pragma mark 子视图
-(void)initAndAddOtherSubview{
    UIView* levelBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.frame.size.height*0.8, self.frame.size.width*0.8, self.frame.size.height*0.8)];
    levelBaseView.backgroundColor = [UIColor colorWithRed:102/255.0 green:204.0/255.0 blue:0 alpha:1.0];
    levelBaseView.center = CGPointMake(self.frame.size.width/2, 0);
    levelBaseView.layer.cornerRadius = 10.0;
    levelBaseView.layer.masksToBounds = YES;
    levelBaseView.tag = 1000;
    [self addSubview:levelBaseView];
    
    self.theAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[levelBaseView]];
    [self.theAnimator addBehavior:gravityBehaviour];
    
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:levelBaseView attachedToAnchor:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [attachmentBehavior setLength:0];
    [attachmentBehavior setDamping:0.3];
    [attachmentBehavior setFrequency:3];
    [attachmentBehavior setAction:^{
        _count++;
        if (_count == 40) {
            UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 80, levelBaseView.bounds.size.width, levelBaseView.bounds.size.height-130)];
            scrollview.pagingEnabled = YES;
            scrollview.scrollEnabled = YES;
            scrollview.bounces = YES;
            scrollview.clipsToBounds = NO;
            scrollview.showsHorizontalScrollIndicator = NO;
            scrollview.showsVerticalScrollIndicator = NO;
            scrollview.scrollsToTop = NO;
            scrollview.contentSize = CGSizeMake(scrollview.frame.size.width *3, scrollview.frame.size.height);
            scrollview.contentOffset = CGPointMake(0, 0);
            scrollview.tag = 1100;
            scrollview.delegate = self;
            [levelBaseView addSubview:scrollview];
            
            UICollectionViewFlowLayout *collectionviewflow = [[UICollectionViewFlowLayout alloc] init];
            UICollectionView* collectionViewLevel1 = [[UICollectionView alloc] initWithFrame:CGRectMake(20, 20, levelBaseView.bounds.size.width-40, scrollview.bounds.size.height - 40) collectionViewLayout:collectionviewflow];
            collectionViewLevel1.dataSource = self;
            collectionViewLevel1.delegate = self;
            collectionViewLevel1.backgroundColor = [UIColor clearColor];
            //注册CollectionViewCellLevell的identifier
            [collectionViewLevel1 registerClass:[CollectionViewCellLevel class] forCellWithReuseIdentifier:@"collectionidentiferLevel"];
            collectionViewLevel1.tag = 1110;
            [scrollview addSubview:collectionViewLevel1];
        }
        
        if (_count == 45) {
            [self diguiAnimation];
        }
    }];
    [self.theAnimator addBehavior:attachmentBehavior];
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, levelBaseView.bounds.size.height - 70,  levelBaseView.bounds.size.width, 20)];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.numberOfPages = 3;
    pageControl.tag = 1200;
    [levelBaseView addSubview:pageControl];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, levelBaseView.frame.size.height - 50, levelBaseView.bounds.size.width, 50)];
    button.backgroundColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"返回主页" forState:UIControlStateNormal];
    button.tag = 1300;
    [button addTarget:self action:@selector(buttonPressedGoback:) forControlEvents:UIControlEventTouchUpInside];
    [levelBaseView addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, levelBaseView.frame.size.width, 80)];
    label.backgroundColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:1.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"关卡选择";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:24];
    label.tag = 1400;
    [levelBaseView addSubview:label];
}

-(void)buttonPressedGoback:(id)sender{
    [self.theAnimator removeAllBehaviors];
    
    UIView *levelBaseView = (UIView *)[self viewWithTag:0];
    [UIView animateWithDuration:0.3 animations:^{
        levelBaseView.frame = CGRectMake(levelBaseView.frame.origin.x, -levelBaseView.frame.size.height, levelBaseView.frame.size.width, levelBaseView.frame.size.height);
    } completion:^(BOOL isfinish){
        [self removeFromSuperview];
    }];
}

#pragma mark -
#pragma mark UIScrollerView的代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    UIPageControl *pageview = (UIPageControl *)[self viewWithTag:1200];
    pageview.currentPage = page;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    UICollectionView *collection = (UICollectionView *)[self viewWithTag:1110];
    if (collection) {
        [collection removeFromSuperview];
    }
    
    _cellImageNum = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    UICollectionViewFlowLayout *collectionviewflow = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView* collectionViewLevel1 = [[UICollectionView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width*page + 20, 20, scrollView.bounds.size.width-40, scrollView.bounds.size.height - 40) collectionViewLayout:collectionviewflow];
    collectionViewLevel1.dataSource = self;
    collectionViewLevel1.delegate = self;
    collectionViewLevel1.backgroundColor = [UIColor clearColor];
    //注册CollectionViewCellLevell的identifier
    [collectionViewLevel1 registerClass:[CollectionViewCellLevel class] forCellWithReuseIdentifier:@"collectionidentiferLevel"];
    collectionViewLevel1.tag = 1110;
    [scrollView addSubview:collectionViewLevel1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self diguiAnimation];
    });
}

#pragma mark -
#pragma mark UICollection的代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 5*6;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionView *collectionViewLevel = (UICollectionView *)[self viewWithTag:1110];
    int ylen = collectionViewLevel.frame.size.height/6;
    int xlen = collectionViewLevel.frame.size.width/5;
    
    return CGSizeMake(xlen, ylen);
}

//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//cell的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCellLevel *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionidentiferLevel" forIndexPath:indexPath];
    
    NSDictionary *dicLevelInfos = [_arrayGuanka objectAtIndex:indexPath.row];
    int startNum = [[dicLevelInfos objectForKey:levelinfoStarNum] intValue];
    UIImage *imageclose = nil;
    if (startNum > 0) {
        imageclose = [UIImage imageNamed:@"guankaopen.png"];
    }else{
        imageclose = [UIImage imageNamed:@"guankaclose.png"];
    }
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(collectionView.frame.size.width+cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)];
    imageview.tag = 5000+indexPath.row;
    cell.tag = 6000+indexPath.row;
    imageview.image = imageclose;
    [collectionView addSubview:imageview];
    return cell;
}

-(void)diguiAnimation{
    int tag = 5000+_cellImageNum;
    int celltag = 6000 + _cellImageNum;
    _cellImageNum++;
    UIImageView *imageview = (UIImageView*)[self viewWithTag:tag];
    UICollectionView *collectionview = (UICollectionView *)[self viewWithTag:1110];
    CollectionViewCellLevel *cell = (CollectionViewCellLevel *)[collectionview viewWithTag:celltag];
    if (imageview && cell) {
        [UIView animateWithDuration:0.05 animations:^{
            imageview.frame = cell.frame;
        } completion:^(BOOL isfinish){
            [imageview removeFromSuperview];
            imageview.frame = cell.bounds;
            [cell addSubview:imageview];
            [self diguiAnimation];
        }];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    CollectionViewControllerPlay *collecPlay = [[CollectionViewControllerPlay alloc] initWithCollectionViewLayout:flowlayout];
    collecPlay.view.backgroundColor = [UIColor whiteColor];
    collecPlay.collectionView.backgroundColor = [UIColor whiteColor];
    NSDictionary *dicLevels = [_arrayGuanka objectAtIndex:indexPath.row];
    //每一关的参数设置
    int timeLimit = [[dicLevels objectForKey:levelinfoTime] intValue];
    int widthNum = [[dicLevels objectForKey:levelinfoWidthNum] intValue];
    int colorNum = [[dicLevels objectForKey:levelinfoColorNum] intValue];
    
    collecPlay.timeLimit = timeLimit;
    collecPlay.gameLevelIndex = (int)indexPath.row;
    collecPlay.widthNum = widthNum;
    collecPlay.gameInitTypeNum = colorNum;
    
    [self.viewController addChildViewController:collecPlay];
    [self.viewController.view addSubview:collecPlay.view];
    collecPlay.view.alpha = 0.0;
//    CGRect rectPre = collecPlay.view.frame;
//    collecPlay.view.frame = CGRectMake(-rectPre.size.width, rectPre.origin.y, rectPre.size.width, rectPre.size.height);
    [UIView animateWithDuration:0.3 animations:^{
//        collecPlay.view.frame = rectPre;
        collecPlay.view.alpha = 1.0;
    }];
}

#pragma mark - notification
-(void)playingViewExitNotificationResponse:(id)sender{
    UIScrollView *scrollview = (UIScrollView *)[self viewWithTag:1100];
    [self scrollViewDidEndDecelerating:scrollview];
}
@end
