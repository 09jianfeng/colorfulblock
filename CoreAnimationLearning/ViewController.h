//
//  ViewController.h
//  CoreAnimationLearning
//
//  Created by JFChen on 15/4/19.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

typedef NS_ENUM(int,GameDifficultyLevel){
    GameDifficultyLevel1=0,
    GameDifficultyLevel2,
    GameDifficultyLevel3,
    GameDifficultyLevel4
};

@interface ViewController : UIViewController <GKGameCenterControllerDelegate>


@end

