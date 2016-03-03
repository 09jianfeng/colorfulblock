//
//  GameAudioPlay.m
//  zhuankuaicolor
//
//  Created by JFChen on 16/2/27.
//  Copyright © 2016年 JFChen. All rights reserved.
//

#import "GameAudioPlay.h"

@interface GameAudioPlay()
@property(nonatomic, retain) AVAudioPlayer *audioplayerCorrect;
@property(nonatomic, retain) AVAudioPlayer *audioplayerError;
@property(nonatomic, retain) AVAudioPlayer *audioNumAdding;
@property(nonatomic, retain) AVAudioPlayer *audioMain;
@end

@implementation GameAudioPlay

-(id)init{
    self = [super init];
    if (self) {
        //1.音频文件的url路径
        NSURL *url=[[NSBundle mainBundle]URLForResource:@"music_num_add.mp3" withExtension:Nil];
        //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
        AVAudioPlayer *audioNumAdding=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
        //3.缓冲
        [audioNumAdding prepareToPlay];
        self.audioNumAdding = audioNumAdding;
    }
    return self;
}

-(void)playAudioWithFileName:(NSString *)audioFileName{
    //1.音频文件的url路径
    NSURL *url=[[NSBundle mainBundle]URLForResource:audioFileName withExtension:Nil];
    //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
    AVAudioPlayer *audioplayerCorrect=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
    //3.缓冲
    [audioplayerCorrect prepareToPlay];
    [audioplayerCorrect play];
    self.audioplayerCorrect = audioplayerCorrect;
}

+(id)shareInstance{
    static GameAudioPlay *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [GameAudioPlay new];
    });
    return instance;
}

+(void)playClickBlockAudio:(BOOL)isError{
    NSString *audioFileName = @"";
    if (isError) {
        audioFileName = @"music_click_correct.mp3";
    }else{
        audioFileName = @"music_click_error.mp3";
    }
    [[GameAudioPlay shareInstance] playAudioWithFileName:audioFileName];
}

+(void)playNumAddingAudio{
    [[GameAudioPlay shareInstance] playAudioWithFileName:@"music_num_add.mp3"];
}

-(void)playMainAud{
    //1.音频文件的url路径
    NSURL *url=[[NSBundle mainBundle] URLForResource:@"music_main.mp3" withExtension:Nil];
    //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
    AVAudioPlayer *audioplayerCorrect=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
    //3.缓冲
    [audioplayerCorrect prepareToPlay];
    [audioplayerCorrect play];
    audioplayerCorrect.numberOfLoops = 1000000;
    self.audioMain = audioplayerCorrect;
}

+(void)playMainAudio{
    [[GameAudioPlay shareInstance] playMainAud];
}

+(void)stopMainAudio{
}

+(void)playViewChangeAudio{
    [[GameAudioPlay shareInstance] playAudioWithFileName:@"music_level.mp3"];
}

+(void)playViewSwitchAudio{
    [[GameAudioPlay shareInstance] playAudioWithFileName:@"music_screen_switch.mp3"];
}
@end
