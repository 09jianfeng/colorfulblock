//
//  ProGressView.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/26.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "ProGressView.h"

@interface ProGressView()
@property(nonatomic, retain) UIImageView *innerView;
@end

@implementation ProGressView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.innerView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, frame.size.height)];
        self.innerView.image = [UIImage imageNamed:@"bg_progress_02"];
        [self addSubview:_innerView];
        
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 0.0;
        self.layer.cornerRadius = 2.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

//process是％分制的
-(void)setprocess:(float)process{
    float width = self.frame.size.width * process;
    self.innerView.frame = CGRectMake(0.0, 0.0, width, self.frame.size.height);
}
@end
