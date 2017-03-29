//
//  CollectionViewCellLevel.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/30.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "CollectionViewCellLevel.h"

@implementation CollectionViewCellLevel
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"CollectionViewCellLevel" owner:self options:nil];
        if (array.count < 1) {
            return nil;
        }
        
        if (![[array objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [array objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

@end
