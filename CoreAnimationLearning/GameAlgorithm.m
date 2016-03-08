//
//  GameAlgorithm.m
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/25.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "GameAlgorithm.h"

@interface GameAlgorithm(){
    //表格盘总数
    int a[30][30];
    //随机的时候用
    int b[900];
}

//所有彩色砖头的数量
@property(nonatomic,assign) int allValueblockNum;
//所有砖头的种类
@property(nonatomic,assign) int blockTypeNum;

//横向有多少个表格
@property(nonatomic,assign) int widthNum;
//竖向有多少个表格
@property(nonatomic,assign) int heightNum;
@end


@implementation GameAlgorithm
-(id)initWithWidthNum:(int)widthNum heightNum:(int)heightNum gamecolorexternNum:(int)gamecolorexternNum allblockNumpercent:(float)allblockNumpercent{
    self = [super init];
    if (self) {
        self.blockTypeNumpercent = 0.03;
        self.allblockNumpercent = 0.65;
        [self initTable:widthNum heightNum:heightNum gamecolorexternNum:gamecolorexternNum allblockNumpercent:allblockNumpercent];
    }
    return self;
}

-(void)initTable:(int)widthNum heightNum:(int)heightNum gamecolorexternNum:(int)gamecolorexternNum allblockNumpercent:(float)allblockNumpercent{
    for (int i = 0; i < widthNum; i++) {
        for (int j = 0; j < heightNum; j++) {
            a[i][j] = 0;
            b[heightNum*i + j] = heightNum*i + j;
        }
    }
    
    self.widthNum = widthNum;
    self.heightNum = heightNum;
    self.allValueblockNum = widthNum * heightNum * allblockNumpercent;
    self.blockTypeNum = gamecolorexternNum;
    //最多有12种颜色
    if(self.blockTypeNum > 12) self.blockTypeNum = 12;
    
    int allblockNum = widthNum*heightNum;
    for (int i = 0; i < _allValueblockNum; i+=2) {
        int BLOCKCOLORrandom = arc4random()%(_blockTypeNum)+1;
        for (int j = 0; j < 2; j++) {
            
            int endIndex = allblockNum - i - j-1;
            if (endIndex == 0) {
                return;
            }
            int blockLocationrandom = arc4random()%(endIndex);
            //从b数组中取出值
            int aGetValueIndex = b[blockLocationrandom];
            //给a数组的某个位置赋颜色值
            int widthindex = aGetValueIndex%_widthNum;
            int heightIndex = aGetValueIndex/_widthNum;
            a[heightIndex][widthindex] = BLOCKCOLORrandom;
            //把赋值了的位置移到b数组的最后面
            b[blockLocationrandom] = b[endIndex];
            b[endIndex] = -1;
        }
    }
}

//彩色砖块总数
-(int)getAllValueBlockNum{
    return _allValueblockNum;
}

//输入位置返回颜色
-(BLOCKCOLOR)getColorInthisPlace:(int)index{
    int widthindex = index%_widthNum;
    int heightIndex = index/_widthNum;
    return a[heightIndex][widthindex];
}

-(NSArray *)getRestColorfulBlockIndexs{
    NSMutableArray *restBlocks = [[NSMutableArray alloc] init];
    for (int i = 0; i < _widthNum*_heightNum; i++) {
        BLOCKCOLOR color = [self getColorInthisPlace:i];
        if (color != BLOCKCOLORnone) {
            [restBlocks addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    return restBlocks;
}

-(NSArray *)getplacethatShoulddrop:(int)index placeShouldUpdate:(NSMutableArray **)mutableShouldUpdateAll{
    int widthindex = index%_widthNum;
    int heightIndex = index/_widthNum;
    if(a[heightIndex][widthindex] > 0) return [NSArray array];
    
    NSMutableArray *mutableShouldDrop = [[NSMutableArray alloc] init];
    *mutableShouldUpdateAll = [[NSMutableArray alloc] init];
    NSMutableArray *mutableShouldUpdateLeft = [[NSMutableArray alloc] init];
    NSMutableArray *mutableShouldUpdateRight = [[NSMutableArray alloc] init];
    NSMutableArray *mutableShouldUpdateDown = [[NSMutableArray alloc] init];
    NSMutableArray *mutableShouldUpdateUp = [[NSMutableArray alloc] init];
    
    //最多有20个颜色值
    int colorIndex[20];
    //初始化
    for (int i = 0; i < 20; i++) {
        colorIndex[i] = -1;
    }
    
    //x方向左寻找，heightIndex不变
    for(int i = widthindex-1;i >= 0;i--){
        [mutableShouldUpdateLeft addObject:[NSNumber numberWithInt:heightIndex*_widthNum+i]];
        if(a[heightIndex][i] > 0){
            int colorValue = a[heightIndex][i];
            //转换成一维数组的下标
            colorIndex[colorValue] = heightIndex*_widthNum+i;
            break;
        };
    }
    
    //x方向右寻找，heightInde不变
    for(int i = widthindex+1;i < _widthNum;i++){
        [mutableShouldUpdateRight addObject:[NSNumber numberWithInt:heightIndex*_widthNum+i]];
        
        if(a[heightIndex][i] > 0){
            int colorValue = a[heightIndex][i];
            //如果对应的颜色已经有值，则说明十字线上有同颜色的，纪录下来
            if (colorIndex[colorValue] >= 0) {
                //记下以前那个值
                NSNumber *number = [NSNumber numberWithInt:colorIndex[colorValue]];
                [mutableShouldDrop addObject:number];
                number = [NSNumber numberWithInt:(heightIndex*_widthNum+i)];
                [mutableShouldDrop addObject:number];
                int width = colorIndex[colorValue]%_widthNum;
                int height = colorIndex[colorValue]/_widthNum;
                //去除这两个位置的颜色
                a[height][width] = 0;
                a[heightIndex][i] = 0;
                [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateRight];
                [mutableShouldUpdateRight removeAllObjects];
                [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateLeft];
                [mutableShouldUpdateLeft removeAllObjects];
            }
            //转换成一维数组的下标
            colorIndex[colorValue] = heightIndex*_widthNum+i;
            
            break;
        };
    }
    
    //y方向向下,widthindex不变
    for(int i = heightIndex+1; i < _heightNum ; i++){
        [mutableShouldUpdateDown addObject:[NSNumber numberWithInt:i*_widthNum+widthindex]];
        
        if (a[i][widthindex] > 0) {
            int colorVaule = a[i][widthindex];
            if (colorIndex[colorVaule] >= 0) {
                //记下以前那个值
                NSNumber *number = [NSNumber numberWithInt:colorIndex[colorVaule]];
                [mutableShouldDrop addObject:number];
                number = [NSNumber numberWithInt:(i*_widthNum+widthindex)];
                [mutableShouldDrop addObject:number];
                
                int width = colorIndex[colorVaule]%_widthNum;
                int height = colorIndex[colorVaule]/_widthNum;
                //去除这两个位置的颜色
                a[height][width] = 0;
                a[i][widthindex] = 0;
                [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateDown];
                [mutableShouldUpdateDown removeAllObjects];
                if (width < widthindex) {
                    [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateLeft];
                    [mutableShouldUpdateLeft removeAllObjects];
                }else{
                    [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateRight];
                    [mutableShouldUpdateRight removeAllObjects];
                }
            }
            colorIndex[colorVaule] = i*_widthNum+widthindex;
            break;
        }
    }
    
    //y方向向上,widthindex不变
    for(int i = heightIndex-1; i >= 0 ; i--){
        [mutableShouldUpdateUp addObject:[NSNumber numberWithInt:i*_widthNum+widthindex]];
        
        if (a[i][widthindex] > 0) {
            int colorVaule = a[i][widthindex];
            if (colorIndex[colorVaule] >= 0) {
                //记下以前那个值
                NSNumber *number = [NSNumber numberWithInt:colorIndex[colorVaule]];
                [mutableShouldDrop addObject:number];
                number = [NSNumber numberWithInt:(i*_widthNum+widthindex)];
                [mutableShouldDrop addObject:number];
                
                int width = colorIndex[colorVaule]%_widthNum;
                int height = colorIndex[colorVaule]/_widthNum;
                //去除这两个位置的颜色
                a[height][width] = 0;
                a[i][widthindex] = 0;
                
                [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateUp];
                if (width < widthindex) {
                    [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateLeft];
                    [mutableShouldUpdateLeft removeAllObjects];
                }else if(width > widthindex){
                    [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateRight];
                    [mutableShouldUpdateRight removeAllObjects];
                }else{
                    [*mutableShouldUpdateAll addObjectsFromArray:mutableShouldUpdateDown];
                    [mutableShouldUpdateDown removeAllObjects];
                }
            }
            colorIndex[colorVaule] = i*_widthNum+widthindex;
            break;
        }
    }
    
    return mutableShouldDrop;
}


//是否还有砖块可以消除
-(void)isHaveBlockToDestroy:(void(^)(BOOL isHave,BOOL isPerfectPlay))callbackBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL isPerfect = YES;
        for (int i = 0; i < _widthNum; i++) {
            for (int j = 0; j < _heightNum; j++) {
                if (a[j][i] > 0) {
                    isPerfect = NO;
                }
                
                NSArray *arr = [self getplacethatShoulddrop:i heightindex:j];
                if (arr.count > 0) {
                    isPerfect = NO;
                    callbackBlock(YES,isPerfect);
                    return;
                }
            }
        }
        
        callbackBlock(NO,isPerfect);
    });
}

-(NSArray *)getplacethatShoulddrop:(int)widthindexa heightindex:(int)heightindexa{
    int widthindex = widthindexa;
    int heightIndex = heightindexa;
    if(a[heightIndex][widthindex] > 0) return [NSArray array];
    
    NSMutableArray *mutable = [[NSMutableArray alloc] init];
    //最多有20个颜色值
    int colorIndex[20];
    //初始化
    for (int i = 0; i < 20; i++) {
        colorIndex[i] = -1;
    }
    
    //x方向左寻找，heightIndex不变
    for(int i = widthindex;i >= 0;i--){
        if(a[heightIndex][i] > 0){
            int colorValue = a[heightIndex][i];
            //转换成一维数组的下标
            colorIndex[colorValue] = heightIndex*_widthNum+i;
            break;
        };
    }
    
    //x方向右寻找，heightInde不变
    for(int i = widthindex;i < _widthNum;i++){
        if(a[heightIndex][i] > 0){
            int colorValue = a[heightIndex][i];
            //如果对应的颜色已经有值，则说明十字线上有同颜色的，纪录下来
            if (colorIndex[colorValue] >= 0) {
                //记下以前那个值
                NSNumber *number = [NSNumber numberWithInt:colorIndex[colorValue]];
                [mutable addObject:number];
                number = [NSNumber numberWithInt:(heightIndex*_widthNum+i)];
                [mutable addObject:number];
            }
            //转换成一维数组的下标
            colorIndex[colorValue] = heightIndex*_widthNum+i;
            break;
        };
    }
    
    //y方向向下,widthindex不变
    for(int i = heightIndex; i < _heightNum ; i++){
        if (a[i][widthindex] > 0) {
            int colorVaule = a[i][widthindex];
            if (colorIndex[colorVaule] >= 0) {
                //记下以前那个值
                NSNumber *number = [NSNumber numberWithInt:colorIndex[colorVaule]];
                [mutable addObject:number];
                number = [NSNumber numberWithInt:(i*_widthNum+widthindex)];
                [mutable addObject:number];
            }
            colorIndex[colorVaule] = i*_widthNum+widthindex;
            break;
        }
    }
    
    //y方向向上,widthindex不变
    for(int i = heightIndex; i >= 0 ; i--){
        if (a[i][widthindex] > 0) {
            int colorVaule = a[i][widthindex];
            if (colorIndex[colorVaule] >= 0) {
                //记下以前那个值
                NSNumber *number = [NSNumber numberWithInt:colorIndex[colorVaule]];
                [mutable addObject:number];
                number = [NSNumber numberWithInt:(i*_widthNum+widthindex)];
                [mutable addObject:number];
            }
            colorIndex[colorVaule] = i*_widthNum+widthindex;
            break;
        }
    }
    
    return mutable;
}

@end
