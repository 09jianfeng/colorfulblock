//
//  GameAlgorithm.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/25.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    blockcolornone = 0,
    blockcolor1,
    blockcolor2,
    blockcolor3,
    blockcolor4,
    blockcolor5,
    blockcolor6,
    blockcolor7,
    blockcolor8,
    blockcolor9,
    blockcolor10,
    blockcolor11,
    blockcolor12,
    blockcolor13
}blockcolor;

@interface GameAlgorithm : NSObject
@property(nonatomic,assign) float blockTypeNumpercent;
@property(nonatomic,assign) float allblockNumpercent;

-(id)initWithWidthNum:(int)widthNum heightNum:(int)heightNum gamecolorexternNum:(int)gamecolorexternNum allblockNumpercent:(float)allblockNumpercent;

//输入位置返回颜色
-(blockcolor)getColorInthisPlace:(int)index;

//最多返回六个位置，有可能返回重复的位置。要注意判断
-(NSArray *)getplacethatShoulddrop:(int)index placeShouldUpdate:(NSMutableArray **)mutableShouldDrop;

//是否还有砖块可以消除
-(void)isHaveBlockToDestroy:(void(^)(BOOL isHave,BOOL isPerfectPlay))callbackBlock;

//彩色砖块总数
-(int)getAllValueBlockNum;
@end
