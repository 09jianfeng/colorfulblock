//
//  GameAlgorithm.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/25.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    BLOCKCOLORnone = 0,
    BLOCKCOLOR1,
    BLOCKCOLOR2,
    BLOCKCOLOR3,
    BLOCKCOLOR4,
    BLOCKCOLOR5,
    BLOCKCOLOR6,
    BLOCKCOLOR7,
    BLOCKCOLOR8,
    BLOCKCOLOR9,
    BLOCKCOLOR10,
    BLOCKCOLOR11,
    BLOCKCOLOR12,
    BLOCKCOLOR13
}BLOCKCOLOR;

@interface GameAlgorithm : NSObject
@property(nonatomic,assign) float blockTypeNumpercent;
@property(nonatomic,assign) float allblockNumpercent;

-(id)initWithWidthNum:(int)widthNum heightNum:(int)heightNum gamecolorexternNum:(int)gamecolorexternNum allblockNumpercent:(float)allblockNumpercent;

///输入位置返回颜色
-(BLOCKCOLOR)getColorInthisPlace:(int)index;

///最多返回六个位置，有可能返回重复的位置。要注意判断
-(NSArray *)getplacethatShoulddrop:(int)index placeShouldUpdate:(NSMutableArray **)mutableShouldDrop;

///是否还有砖块可以消除
-(void)isHaveBlockToDestroy:(void(^)(BOOL isHave,BOOL isPerfectPlay))callbackBlock;

///彩色砖块总数
-(int)getAllValueBlockNum;

///返回剩余的彩色砖块位置数组
-(NSArray *)getRestColorfulBlockIndexs;
@end
