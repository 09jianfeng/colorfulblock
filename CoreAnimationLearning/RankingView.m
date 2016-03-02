//
//  RankingView.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/3/2.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "RankingView.h"

@interface RankingView()<UIScrollViewDelegate>
@property(nonatomic,retain) UIDynamicAnimator *ani;
@property(nonatomic,retain) UIGravityBehavior *gravity;
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
    board.layer.borderColor = [UIColor whiteColor].CGColor;
    [self addSubviewForBoard:board];
    [self addGravityAnimation:board];
}

-(void)addSubviewForBoard:(UIView *)board{
    float boardUnitHeigh = CGRectGetHeight(board.frame)/4.0;
    float scrollViewHeigh = boardUnitHeigh *3.0;
    float scrollViewWidth = board.frame.size.width;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeigh)];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(board.frame.size.width * 4.0, scrollViewHeigh);
    NSArray *textArray = @[@"简单模式",@"历史最高：500",@"完美拆除：5",@"hehehhe"];
    for (int i = 0; i < 3; i++) {
        UIView *subView = [self subViewForScrollView:textArray[i] bestPoint:0 perfectTimes:0 viewFrame:CGRectMake(scrollViewWidth * i, 0, scrollViewWidth, scrollViewHeigh)];
        subView.backgroundColor = [UIColor colorWithWhite:i/4.0 alpha:1.0];
        [scrollView addSubview:subView];
    }
    scrollView.contentOffset = CGPointMake(0, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    [board addSubview:scrollView];
    
    float buttonHeigh = board.frame.size.height/5.0;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(buttonHeigh,board.frame.size.height - buttonHeigh*1.5, buttonHeigh, buttonHeigh);
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(buttonPressedBack:) forControlEvents:UIControlEventTouchUpInside];
    [board addSubview:button];
}

-(UIView *)subViewForScrollView:(NSString *)title bestPoint:(int)bestPoint perfectTimes:(int)perfectTimes viewFrame:(CGRect)viewFrame{
    UIView *subViewInScrollView = [[UIView alloc] initWithFrame:viewFrame];
    float unitHeigh = viewFrame.size.height/16.0;
    float textwidth = viewFrame.size.width;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeigh, textwidth, unitHeigh*4)];
    labelTitle.text = title;
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    labelTitle.font = [UIFont boldSystemFontOfSize:23];
    [subViewInScrollView addSubview:labelTitle];
    
    UILabel *labelBestPoint = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeigh * 6, textwidth, unitHeigh*4)];
    labelBestPoint.text = title;
    labelBestPoint.textAlignment = NSTextAlignmentCenter;
    labelBestPoint.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    labelBestPoint.font = [UIFont boldSystemFontOfSize:23];
    [subViewInScrollView addSubview:labelBestPoint];

    UILabel *labelPerfect = [[UILabel alloc] initWithFrame:CGRectMake(0, unitHeigh * 11, textwidth, unitHeigh*4)];
    labelPerfect.text = title;
    labelPerfect.textAlignment = NSTextAlignmentCenter;
    labelPerfect.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
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
    [self removeFromSuperview];
}

#pragma mark - UIScrollView delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}


@end
