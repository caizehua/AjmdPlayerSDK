//
//  FMPlayerDriver.m
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "AjmdPlayer.h"
#import "FMPlayerDriver.h"
#import "FMPlayerManager.h"
#import "FMDataManager.h"
#import "FMDataPluginBase.h"
#import "FMPlayerMacros.h"
#import "FMPlayerManagerProtocol.h"
#import <AVFoundation/AVFoundation.h>

@interface FMPlayerDriver ()<FMPlayerManagerProtocol>

@property (nonatomic,strong)NSMutableArray *servicePlugIns;

@property (nonatomic,strong)NSMutableArray *plugInNames;

@property (nonatomic,assign)BOOL interruputPlayState;

@property (nonatomic,strong)PlayStatus *recordPlayStatus;

@end

@implementation FMPlayerDriver

+ (id)sharedInstance
{
    static FMPlayerDriver *sharedPlayerDriver=nil;
    if (sharedPlayerDriver==nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedPlayerDriver=[[[self class]alloc]init];
        });
    }
    return sharedPlayerDriver;
}
-(id)init
{
    if (self=[super init]) {
        _servicePlugIns=[[NSMutableArray alloc]initWithCapacity:0];
        _plugInNames=[[NSMutableArray alloc]initWithCapacity:0];
        [self registerDataPlugInClass:kDataPlugInBase];
        [[FMPlayerManager sharedInstance]setDelegate:self];
    }
    return self;
}

#pragma mark -PrivateMethods

-(void)registerServicePlugInClass:(FMServicePlugIn *)plugInObj
{
//    Class ServicePlugin=NSClassFromString(name);
//    FMServicePlugIn *plugInObj=[[ServicePlugin alloc]init];
    if ([_plugInNames containsObject:plugInObj.serviceName]) {
        NSLog(@"--%@服务插件已经存在-----",plugInObj.serviceName);
    }
    else
    {
        [_servicePlugIns addObject:plugInObj];
        [_plugInNames addObject:plugInObj.serviceName];
        NSLog(@"--%@服务插件注册成功-----",plugInObj.serviceName);
    }
    
}

-(void)unRegisterServicePlugInClass:(FMServicePlugIn *)plugInObj
{
//    Class ServicePlugin=NSClassFromString(name);
//    FMServicePlugIn *plugInObj=[[ServicePlugin alloc]init];
    if ([_plugInNames containsObject:plugInObj.serviceName]) {
        NSInteger plugIndex=[_plugInNames indexOfObject:plugInObj.serviceName];
        [_plugInNames removeObjectAtIndex:plugIndex];
        [_servicePlugIns removeObjectAtIndex:plugIndex];
        NSLog(@"--%@服务插件注销成功-----",plugInObj.serviceName);
    }
    else
    {
        NSLog(@"--%@服务插件不存在-----",plugInObj.serviceName);
    }
    
}
- (NSArray *)getServicePlugInNames
{
    return _plugInNames;
}

- (NSArray *)getFormats
{
    return [[FMDataManager sharedInstance]formats];
}
-(void)previous
{
    if ([[FMPlayerManager sharedInstance] getPlayingIndex]>0) {
        [[FMPlayerManager sharedInstance]playforType:PlayIndexTypeOrderId index:([[FMPlayerManager sharedInstance] getPlayingIndex]-1)];
    }
    else
    {
        NSLog(@"----已经到第一首，无法切换----");
    }
}

-(void)next
{
    if ([[FMPlayerManager sharedInstance] getPlayingIndex]<([[FMPlayerManager sharedInstance] getPlayListCount]-1)) {
        [[FMPlayerManager sharedInstance]playforType:PlayIndexTypeOrderId index:([[FMPlayerManager sharedInstance] getPlayingIndex]+1)];
    }
    else
    {
        NSLog(@"----已经到最后一首，无法切换----");
    }
}

-(void)beAudioActivate
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    /*问题：在启动APP但没有播放音频前，中断了后台音频播放。AVAudioSession相互中断处理。
     *原因：在启动APP初始化时，就调用了下面的setActive，此时会阻断后台音乐的播放.
     *修改：在点击播放时，再setActive
     *描述：1.4.1-20160204-14：希望打开阿基米德APP，在不开始播放时不会切断后台其他app的播放源，
     *           开始播放后就关停其他播放源。AVAudioSession相互中断处理。
     */
    //[[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self handleInterrupt];
}



-(void)adaptDataToPlay:(NSArray *)data format:(NSString *)format completed:(void(^)(NSArray *list))block
{
    [[FMDataManager sharedInstance]managerHandleData:data format:format completed:block];
}
-(long)getDefaultAudioIdforUrl:(NSString *)url
{
    return [url hash];
}

-(void)playforType:(PlayIndexType)type index:(long)indexId
{
    [[FMPlayerManager sharedInstance]playforType:type index:indexId];

}
#pragma mark - FMDataProtocol


-(void)registerDataPlugInClass:(NSString *)name
{
    [[FMDataManager sharedInstance]registerDataPlugInClass:name];
}

-(void)unRegisterDataPlugInClass:(NSString *)name
{
    [[FMDataManager sharedInstance]unRegisterDataPlugInClass:name];
}
#pragma mark - FMPlayerManagerDelegate

-(void)didChangePlayState:(PlayStatus *)status
{
    if (![status isEqual:_recordPlayStatus]) {
        _recordPlayStatus=[status clone];
    }
    
    [_servicePlugIns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didChangePlayState:)]) {
            [obj didChangePlayState:status];
        }
    }];
}
-(void)didChangePlayList:(NSArray *)playList index:(NSUInteger)index changeType:(PlayListChangeType)type
{
    [_servicePlugIns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(didChangePlayList:index:changeType:)]) {
            [obj didChangePlayList:[[FMDataManager sharedInstance]getDetailListInfo:playList] index:index changeType:type];
        }
    }];
}

#pragma mark - FMPlayerListActionProtocol

- (void)setModel:(PlayModel)model
{
    [[FMPlayerManager sharedInstance]setModel:model];
}

//获取音频流的类型：0-hls，1-file
- (int)getFileType
{
    return [[FMPlayer sharedInstance]getFileType];
}

//获取文件时长
- (long)getFileDuration
{
    return [[FMPlayer sharedInstance]getFileDuration];
}

//获取直播还是回听
- (int)getFMLiveState
{
    return [[FMPlayer sharedInstance]getFMLiveState];
}

//可以将直播时长传到底层
- (void)setLiveDuration:(long)time
{
    [[FMPlayer sharedInstance]setLiveDuration:time];
    
}

//获取直播时长
- (long)getLiveDuration
{
    return [[FMPlayer sharedInstance]getLiveDuration];
}

- (void)setLiveTotalDuration:(long)time
{
    [[FMPlayer sharedInstance]setLiveTotalDuration:time];
}

- (void)seek:(long)time
{
    [[FMPlayerManager sharedInstance]seek:time];

}
- (void)stop
{
    [[FMPlayerManager sharedInstance]stop];

}
- (void)pause
{
    [[FMPlayerManager sharedInstance]pause];

}
- (void)resume
{
    [[FMPlayerManager sharedInstance]resume];

}
- (void)togglePause
{
    [[FMPlayerManager sharedInstance]togglePause];
}

#pragma mark - FMPlayerListActionProtocol

- (void)removeList:(NSArray *)sourceList
{
    if ([sourceList containsObject:[NSNumber numberWithLong:[[FMPlayerManager sharedInstance]getPlayAudioIdForIndex:[[FMPlayerManager sharedInstance]getPlayingIndex]]]]) {
        [[FMPlayerManager sharedInstance]removeList:sourceList];
        [self playforType:PlayIndexTypeOrderId index:[[FMPlayerManager sharedInstance]getPlayingIndex]];
    }
    else
    {
        [[FMPlayerManager sharedInstance]removeList:sourceList];

    }
}
-(void)updateList:(NSArray *)sourceList
{
    [[FMPlayerManager sharedInstance]updateList:sourceList];
}

-(void)updateListWithRepeatedItem:(NSArray *)sourceList
{
    [[FMPlayerManager sharedInstance]updateListWithRepeatedItem:sourceList];
}


- (void)resetList
{
    [[FMPlayerManager sharedInstance]resetList];
}

#pragma mark - AudioInterruptHandleMethods

-(void)handleInterrupt
{
    AudioSessionInitialize(NULL, NULL, interruptionListenner, (__bridge void*)self);
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeListenerCallback, (__bridge void*)self);
}
//播放音乐文件打断处理
void interruptionListenner(void* inClientData, UInt32 inInterruptionState)
{
    FMPlayerDriver *pTHIS=[FMPlayerDriver sharedInstance];
    if (pTHIS) {
        NSLog(@"interruptionListenner %u", (unsigned int)inInterruptionState);
        if (kAudioSessionBeginInterruption == inInterruptionState) {
            NSLog(@"Begin interruption");//开始打断打断处理
            pTHIS.interruputPlayState=NO;
            if ([pTHIS.recordPlayStatus getPlayingState]) {
                pTHIS.interruputPlayState=YES;
                [pTHIS pause];
            }
        }
        else if (inInterruptionState == kAudioSessionEndInterruption)
        {
            NSLog(@"End end interruption");//结束打断处理
            if (pTHIS.interruputPlayState==YES) {
                [pTHIS resume];
                pTHIS.interruputPlayState=NO;
            }
        }
        
    }
}

void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    // Determines the reason for the route change, to ensure that it is not
    //        because of a category change.
    
    CFDictionaryRef    routeChangeDictionary = inPropertyValue;
    CFNumberRef routeChangeReasonRef =
    CFDictionaryGetValue (routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    NSLog(@" ======================= RouteChangeReason : %d", routeChangeReason);
    FMPlayerDriver *pTHIS=[FMPlayerDriver sharedInstance];
    if (pTHIS) {
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            
            
            //Handle Headset Unplugged
            if (![pTHIS hasHeadset]) {
                if ([pTHIS.recordPlayStatus getPlayingState]) {
                    [pTHIS pause];
                }
            }
            
        } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            
            //Handle Headset plugged in
            
        }else if (routeChangeReason == kAudioSessionRouteChangeReason_CategoryChange)
        {
            //支持录音机后，category设置会变化。录音时，暂停ajmide play播放。
            //category从playback变化到record
            if ([pTHIS.recordPlayStatus getPlayingState]) {
                [pTHIS pause];
            }
            
            //录音结束后，category设置会变化。category从record变化成playback
            //这种情况不在这里做处理
        }
    }
}

- (BOOL)hasHeadset {
    
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

@end
