//
//  GameCenter.m
//  chaigangkuai
//
//  Created by JFChen on 15/6/9.
//  Copyright (c) 2015年 JFChen. All rights reserved.
//

#import "GameCenter.h"
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "macro.h"

@implementation GameCenter

#pragma mark - 用户登录, 验证用户是否登陆
- (void) authenticateLocalPlayer
{
    [[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController,NSError *error){
        if (viewController) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewController presentViewController:viewController animated:YES completion:nil];
            });
        }else if(!error){
            //成功处理
//            NSLog(@"成功");
//            NSLog(@"1--alias--.%@",[GKLocalPlayer localPlayer].alias);
//            NSLog(@"2--authenticated--.%d",[GKLocalPlayer localPlayer].authenticated);
//            NSLog(@"3--isFriend--.%d",[GKLocalPlayer localPlayer].isFriend);
//            NSLog(@"4--playerID--.%@",[GKLocalPlayer localPlayer].playerID);
//            NSLog(@"5--underage--.%d",[GKLocalPlayer localPlayer].underage);
        }
    }];
}

#pragma mark - 用户变更检测
- (void)registerFoeAuthenticationNotification{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

- (void)authenticationChanged{
    if([GKLocalPlayer localPlayer].isAuthenticated){
        
    }else{
        
    }
}

#pragma mark - 发送分数
//当上传分数出错的时候,要将上传的分数存储起来,比如将SKScore存入一个NSArray中.等可以上传的时候再次尝试.
- (void)reportScore:(int64_t)score forCategory:(NSString*) category
{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:category];
    scoreReporter.value = score;
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error != nil)
        {
            // handle the reporting error
            NSLog(@"上传分数出错.");
            //If your application receives a network error, you should not discard the score.
            //Instead, store the score object and attempt to report the player’s process at
            //a later time.
        }else {
            NSLog(@"上传分数成功");
        }
    }];

}

#pragma mark - 下载分数
/*
 playerScope:表示检索玩家分数范围.
 2)    timeScope:表示某一段时间内的分数
 3)    range:表示分数排名的范围
 4)    category:表示你的Leaderboard的ID.
 */
//GKScore objects provide the data your application needs to create a custom view.
//Your application can use the score object’s playerID to load the player’s alias.
//The value property holds the actual value you reported to Game Center. the formattedValue
//property provides a string with the score value formatted according to the parameters
//you provided in iTunes Connect.
- (void) retrieveTopTenScores
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
        leaderboardRequest.range = NSMakeRange(1,10);
        leaderboardRequest.identifier = @"TS_LB";
        [leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
            if (error != nil){
                // handle the error.
                NSLog(@"下载失败");
            }
            if (scores != nil){
                // process the score information.
                NSLog(@"下载成功....");
                NSArray *tempScore = [NSArray arrayWithArray:leaderboardRequest.scores];
                for (GKScore *obj in tempScore) {
                    NSLog(@"    playerID            : %@",obj.playerID);
                    NSLog(@"    category            : %@",obj.leaderboardIdentifier);
                    NSLog(@"    date                : %@",obj.date);
                    NSLog(@"    formattedValue    : %@",obj.formattedValue);
                    NSLog(@"    value                : %d",(int)obj.value);
                    NSLog(@"    rank                : %d",(int)obj.rank);
                    NSLog(@"**************************************");
                }
            }
        }];
    }
}


#pragma mark - 与好友交互
/*
 Game Center最重要的一个功能就是玩家交互.所以,必须检索已经登录玩家的好友信息.根据自己的需要做出设置,比如,可以与好友比较分数,或者好友排行榜等.
 //检索已登录用户好友列表
 */
- (void) retrieveFriends
{
    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
    if (lp.authenticated)
    {
        [lp loadFriendsWithCompletionHandler:^(NSArray *friends, NSError *error) {
            if (error == nil)
            {
                [self loadPlayerData:friends];
            }
            else
            {
                ;// report an error to the user.
            }
        }];
        
    }
}

/*
 上面的friends得到的只是一个身份列表,里面存储的是NSString,想要转换成好友ID,必须调用- (void) loadPlayerData: (NSArray *) identifiers方法,该方法得到的array里面存储的才是GKPlayer对象.如下
 Whether you received player identifiers by loading the identifiers for the local player’s
 friends, or from another Game Center class, you must retrieve the details about that player
 from Game Center.
 */
- (void) loadPlayerData: (NSArray *) identifiers
{
    [GKPlayer loadPlayersForIdentifiers:identifiers withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil)
        {
            // Handle the error.
        }
        if (players != nil)
        {
            NSLog(@"得到好友的alias成功");
            GKPlayer *friend1 = [players objectAtIndex:0];
            NSLog(@"friedns---alias---%@",friend1.alias);
            NSLog(@"friedns---isFriend---%d",friend1.isFriend);
            NSLog(@"friedns---playerID---%@",friend1.playerID);
        }
    }];
}


#pragma mark - 成就
-(void)reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    if (achievement)
    {
        achievement.percentComplete = percent;
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 //The proper way for your application to handle network errors is retain
                 //the achievement object (possibly adding it to an array). Then, periodically
                 //attempt to report the progress until it is successfully reported.
                 //The GKAchievement class supports the NSCoding protocol to allow your
                 //application to archive an achie
                 NSLog(@"报告成就进度失败 ,错误信息为: \n %@",error);
             }else {
                 //对用户提示,已经完成XX%进度
                 NSLog(@"报告成就进度---->成功!");
                 NSLog(@"    completed:%d",achievement.completed);
                 NSLog(@"    lastReportedDate:%@",achievement.lastReportedDate);
                 NSLog(@"    percentComplete:%f",achievement.percentComplete);
                 NSLog(@"    identifier:%@",achievement.identifier);
             }
         }];
    }
}


#pragma mark - 显示gameCenter
- (void)showGameCenter{
    GKGameCenterViewController *gameView = [[GKGameCenterViewController alloc] init];
    if(gameView != nil){
        gameView.gameCenterDelegate = _viewController;
        [_viewController presentViewController:gameView animated:YES completion:^{
            
        }];
    }
}
@end
