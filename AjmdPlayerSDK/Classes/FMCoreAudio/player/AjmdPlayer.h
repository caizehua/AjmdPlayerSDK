//
//  AjmdPlayer.h
//  AjmdPlayer
//
//  Created by beibeihu on 1/5/16.
//  Copyright © 2016 ajmide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMPlayer : NSObject
/*！
 @method      sharedInstance
 @abstract    初始化方法，init一个FMPlayer的实例
 @return      id 一个FMPlayer的实例
 */
+ (id)sharedInstance;

/*！
 @method      Initialize
 @abstract    FMPlayer相关context的创建和初始化
 @return      int 创建结果，0成功，－1异常
 */
- (int)Initialize;

/*！
 @method      Play:source
 @abstract    播放音频
 @param       source
 */
- (void)Play:(NSString *)source;

/*！
 @method      Pause
 @abstract    暂停音频播放
 */
- (void)Pause;

/*！
 @method      Resume
 @abstract    恢复音频播放
 */
- (void)Resume;

/*！
 @method      Seek: time
 @abstract    转到指定时间播放音频
 @param       指定时间，单位毫秒
 */
- (void)Seek:(long)time;

/*！
 @method      GetLiveState
 @abstract    获取当前是直播还是回听状态
 @return
 */
- (int)GetLiveState;

/*！
 @method      GetDuration
 @abstract    获取音频时长
 如果播放的音频是文件格式，返回文件时长；
 如果是HLS，根据是否直播返回时长；
 @return      返回音频时长,单位秒
 */
- (long)GetDuration;

/*！
 @method      Forward: timeStep
 @abstract    音频播放过程中，支持快进，可以定义快进的步长，暂定为一次5秒
 @param       快进的步长
 */
- (void)Forward:(long)timeStep;

/*！
 @method      Rewind: timeStep
 @abstract    音频播放过程中，支持后退，可以定义快退的步长，暂定为一次5秒
 @param       快进的步长
 */
- (void)Rewind:(long)timeStep;

/*！
 @method      Destory
 @abstract    销毁播放器，释放内存
 */
- (void)Destory;

/*！
 上面的方法是定义的播放器通用方法
 下面是为ajmide工程提供的方法，在FMPlayrManager中有调用
 */

- (void)seek:(long)time;

- (int)getFileType;
- (long)getFileDuration;
- (int)getFMLiveState;
- (void)setLiveDuration:(long)duration;
- (long)getLiveDuration;

- (void)play:(NSString *)source;
- (void)play:(NSString *)source forProgram:(long)programId;
- (void)play:(NSString *)source forProgram:(long)programId atTime:(long)seekTime;

- (void)stop;
- (void)pause;
- (void)resume;
- (void)togglePause;

/*！
 @method     checkAudioSource
 @abstract    检查url对应的音频是否可以打开
 @param       音频的url
 @return        0，音频打开成功，小于0，打开异常
 */
-(int)checkAudioSource: (NSString *)url;

//获取当前播放时间
-(long)getCurrentTime;

@end


//开放给AudioPlayerViewController.m
#define PLAY_STATUS_STOP 0x0000
#define PLAY_STATUS_PAUSE 0x0001
#define PLAY_STATUS_PLAY_COMPLETE 0x0002

#define PLAY_STATUS_PLAY 0x1000
#define PLAY_STATUS_PLAY_START 0x1001
#define PLAY_STATUS_BUFFER 0x1002
#define PLAY_STATUS_BUFFER_FULL 0x1004
#define PLAY_STATUS_SEEK_START 0x1010

#define PLAY_STATUS_ERROR 0x2000
//开放给AudioPlayerViewController.m end

@interface PlayStatus : NSObject

@property int connectionId; //didChangePlayState

// 播放状态
@property int state; //didChangePlayState

// 时长 点播为音频的实际大小
@property long duration; //didChangePlayState

// 当前播放时间 已经播放时间
@property long time; //audioPlayerViewController _playState.time

- (int)getPlayingState; //FMPlayerDriver interruptionListenner

- (PlayStatus *)clone; //audioPlayerViewController FMPlayerDriver

- (BOOL)isEqual:(PlayStatus *)ps;

- (NSString *)getStateName; //didChangePlayState

@end


#define kPlayStatusChanged @"playStatusChanged"

#define kPlayStatusKey @"playStatus"

@interface FMPlayerNotificationCenter : NSNotificationCenter

+ (FMPlayerNotificationCenter *)notificationCenter;

@end



