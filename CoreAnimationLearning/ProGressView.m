//
//  ProGressView.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/26.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "ProGressView.h"

@interface ProGressView()
@property(nonatomic, retain) CALayer *innerLayer;
@end

@implementation ProGressView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.innerLayer = [CALayer layer];
        self.innerLayer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg_progress_02"].CGImage);
        self.innerLayer.frame = CGRectMake(0.0, 0.0, 1.0, frame.size.height);
        [self.layer addSublayer:self.innerLayer];
        
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
    width = width > self.frame.size.width ? self.frame.size.width : width;
    self.innerLayer.frame = CGRectMake(0.0, 0.0, width, self.frame.size.height);
}
@end
