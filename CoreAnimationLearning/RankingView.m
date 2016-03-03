//
//  RankingView.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/2.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "RankingView.h"
#import "GameAudioPlay.h"
#import "GameResultData.h"

extern NSString *GAMEBESTPOINTKEY;
extern NSString *GAMEPEFECTTIMESKET;

@interface RankingView()<UIScrollViewDelegate>
@property(nonatomic,retain) UIDynamicAnimator *ani;
@property(nonatomic,retain) UIGravityBehavior *gravity;
@property(nonatomic,retain) UIPageControl *pageControl;
@property(nonatomic,assign) int currentPage;
@end


@implementation RankingView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.ani = [[UIDynamicAnimator alloc] init];
        self.gravity = [[UIGravityBehavior alloc] init];
        [self.ani addBehavior:self.gravity];
    }
    return self;
}

-(void)dealloc{
    self.ani = nil;
    self.gravity = nil;
    self.pageControl = nil;
}

-(void)showView{
    float boardWidth = CGRectGetWidth(self.frame)*3.0/4.0;
    float boardHeigh = boardWidth * 1.5;
    UIView *board = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2.0 - boardWidth/2.0, -self.frame.size.height/2.0 - boardHeigh/2.0, boardWidth, boardHeigh)];
    board.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"playing_background"].CGImage);
    board.backgroundColor = [UIColor clearColor];
    board.layer.cornerRadius = 10.0;
    board.layer.masksToBounds = YES;
    board.layer.borderWidth = 5.0;
    board.tag = 3000;
    board.layer.borderColor = [UIColor whiteColor].CGColor;
    [self addSubviewForBoard:board];
    [self addGravityAnimation:board];
}

-(void)addSubviewForBoard:(UIView *)board{
    float boardUnitHeigh = CGRectGetHeight(board.frame)/4.0;
    float scrollViewHeigh = boardUnitHeigh *3.0;
    float scrollViewWidth = board.frame.size.width;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeigh)];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(board.frame.size.width * 4.0, scrollViewHeigh);
    for (NSInteger  i = 0; i < 4; i++) {
        NSDictionary *levelDicInfo = [[GameResultData getDictionaryOfGameResult] objectAtIndex:i];
        UIView *subView = [self subViewForScrollView:i+1 bestPoint:[levelDicInfo objectForKey:GAMEBESTPOINTKEY] perfectTimes:[levelDicInfo objectForKey:GAMEPEFECTTIMESKET] viewFrame:CGRectMake(scrollViewWidth * i, 0, scrollViewWidth, scrollViewHeigh)];
        [scrollView addSubview:subView];
    }
    scrollView.contentOffset = CGPointMake(0, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    [board addSubview:scrollView];
    
    self.pageControl= [[UIPageControl alloc] initWithFrame:CGRectMake(0, scrollViewHeigh-20, scrollViewWidth, 20)];
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.numberOfPages = 4;
    [self.pageControl setCurrentPage:0];
    [board addSubview:self.pageControl];
    
    float buttonHeigh = boardUnitHeigh/2;
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBack.frame = CGRectMake(buttonHeigh,board.frame.size.height - buttonHeigh*1.5, buttonHeigh, buttonHeigh);
    [buttonBack setImage:[UIImage imageNamed:@"image_back"] forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(buttonPressedBack:) forControlEvents:UIControlEventTouchUpInside];
    [board addSubview:buttonBack];
}

-(UIView *)subViewForScrollView:(GameDifficultyLevel)difLevel bestPoint:(NSString *)bestPoint perfectTimes:(NSString *)perfectTimes viewFrame:(CGRect)viewFrame{
    UIView *subViewInScrollView = [[UIView alloc] initWithFrame:viewFrame];
    float unitHeigh = viewFrame.size.height/16.0;
    float textwidth = viewFrame.size.width;
    
    NSString *title = @"简单模式";
    switch (difLevel) {
        case GameDifficultyLevel1:
            title = @"简单模式";
            break;
        case GameDifficultyLevel2:
            title = @"普通模式";
            break;
        case GameDifficultyLevel3:
            title = @"困难模式";
            break;
        case GameDifficultyLevel4:
            title = @"疯狂模式";
            break;
            
        default:
            break;
    }
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeigh, textwidth, unitHeigh*4)];
    labelTitle.text = title;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont boldSystemFontOfSize:32];
    [subViewInScrollView addSubview:labelTitle];
    
    UILabel *labelBestPoint = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeigh * 6, textwidth, unitHeigh*4)];
    labelBestPoint.text = [NSString stringWithFormat:@"历史最高：%@",bestPoint];
    labelBestPoint.textAlignment = NSTextAlignmentCenter;
    labelBestPoint.textColor = [UIColor whiteColor];
    labelBestPoint.font = [UIFont boldSystemFontOfSize:23];
    [subViewInScrollView addSubview:labelBestPoint];

    UILabel *labelPerfect = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeigh * 11, textwidth, unitHeigh*4)];
    labelPerfect.text = [NSString stringWithFormat:@"完美拆除：%@",perfectTimes];
    labelPerfect.textAlignment = NSTextAlignmentCenter;
    labelPerfect.textColor = [UIColor whiteColor];
    labelPerfect.font = [UIFont boldSystemFontOfSize:23];
    [subViewInScrollView addSubview:labelPerfect];
    return subViewInScrollView;
}

-(void)addGravityAnimation:(UIView *)board{
    [self.gravity addItem:board];
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:board attachedToAnchor:CGPointMake(CGRectGetWidth(self.frame)/2, self.frame.size.height/2)];
    [attachmentBehavior setLength:0];
    [attachmentBehavior setDamping:0.3];
    [attachmentBehavior setFrequency:3];
    [self.ani addBehavior:attachmentBehavior];
    [self addSubview:board];
}

#pragma mark - button click event
-(void)buttonPressedBack:(id)sender{
    [self.ani removeAllBehaviors];
    
    UIView *board = [self viewWithTag:3000];
    [UIView animateWithDuration:0.3 animations:^{
        board.frame = CGRectMake(board.frame.origin.x, -board.frame.size.height, board.frame.size.width, board.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    [GameAudioPlay playViewSwitchAudio];
}

#pragma mark - UIScrollView delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentPage = page;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*self.currentPage, 0) animated:YES];
    [self.pageControl setCurrentPage:self.currentPage];
    [GameAudioPlay playViewChangeAudio];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}

@end
