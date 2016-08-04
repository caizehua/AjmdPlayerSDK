//
//  FMPlayerManager.m
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "FMPlayerManager.h"
#import "AjmdPlayer.h"
#import "FMAudioInfo.h"
#import "FMPlayerMacros.h"


@interface FMPlayerManager ()

@property (nonatomic,strong)NSMutableArray *playList;

@property (nonatomic,strong)NSMutableArray *playIdList;

@property (nonatomic,assign)NSUInteger playIndex;

@property (nonatomic,assign)PlayModel playModel;

@end

@implementation FMPlayerManager

+ (id)sharedInstance
{
    static FMPlayerManager *sharedManager=nil;
    if (sharedManager==nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager=[[[self class]alloc]init];
        });
    }
    return sharedManager;
}

-(id)init
{
    if (self=[super init]) {
        _playList=[NSMutableArray arrayWithCapacity:3];
        _playIdList=[NSMutableArray arrayWithCapacity:3];
        _playIndex=0;
        _playModel=PlayModelOnce;
        [[FMPlayerNotificationCenter notificationCenter] addObserver:self selector:@selector(playStatusChanged:) name:kPlayStatusChanged object:[FMPlayer sharedInstance]];

    }
    return self;
}

#pragma mark - Private Methods

- (void)playStatusChanged:(NSNotification *)notification
{
    PlayStatus *tempStaus= [[notification userInfo] objectForKey:kPlayStatusKey];
    
    if (_delegate&&[_delegate respondsToSelector:@selector(didChangePlayState:)]) {
        [_delegate didChangePlayState:tempStaus];
    }
    
    if (tempStaus.state==PLAY_STATUS_PLAY_COMPLETE) {
        switch (_playModel) {
            case PlayModelOrder:
            {
                if ((_playIndex+1)<_playList.count) {
                    [self playforType:PlayIndexTypeOrderId index:(_playIndex +1)%(_playList.count)];
                }
            }
                break;
            case PlayModelAllRepeat:
            {
                [self playforType:PlayIndexTypeOrderId index:(_playIndex +1)%(_playList.count)];
            }
                break;
            case PlayModelShuffle:
            {
             int value = arc4random()%(_playIdList.count);
            [self playforType:PlayIndexTypeOrderId index:value];

            }
                break;
            case PlayModelRepeatOnce:
            {
                [self playforType:PlayIndexTypeOrderId index:_playIndex];
            }
                break;
                
            default:
                break;
        }
    }

}

-(void)playforType:(PlayIndexType)type index:(long)indexId
{
    @synchronized(_playIdList)
    {
    
        switch (type) {
            case PlayIndexTypeAudioId:
            {
                if (![_playIdList containsObject:[NSNumber numberWithLong:indexId]]) {
                    NSLog(@"----audioId不存在，无法切换---");
                    return;
                }
                [[FMPlayer sharedInstance]stop];
                _playIndex=[_playIdList indexOfObject:[NSNumber numberWithLong:indexId]];
                FMAudioInfo *playAudioInfo=(FMAudioInfo *)[_playList objectAtIndex:_playIndex];
                
                [[FMPlayer sharedInstance]play:playAudioInfo.sourceURL forProgram:playAudioInfo.programId/*audioId*/ atTime:playAudioInfo.skipTime*1000]; //player stat, modify
            }
                break;
            case PlayIndexTypeOrderId:
            {
                if (indexId>=_playIdList.count) {
                    NSLog(@"----index越界，无法切换---");
                    return;
                }
                [[FMPlayer sharedInstance]stop];
                _playIndex=indexId;
                FMAudioInfo *playAudioInfo=(FMAudioInfo *)[_playList objectAtIndex:_playIndex];
              
                
                [[FMPlayer sharedInstance]play:playAudioInfo.sourceURL forProgram:playAudioInfo.programId/*audioId*/ atTime:playAudioInfo.skipTime*1000]; //player stat, modify
            }
                break;
                
            default:
                break;
        }
        if (_delegate&&[_delegate respondsToSelector:@selector(didChangePlayList:index:changeType:)]) {
            [_delegate didChangePlayList:_playIdList index:_playIndex changeType:PlayListChangeTypeIndex];
        }
        NSLog(@"----播放第%ld首---",_playIndex);
        
    }
    
}

#pragma mark - FMPlayActionProtocol

-(void)setModel:(PlayModel)model
{
    _playModel=model;
    NSLog(@"----设置播放模式---%ld",model);
}

- (void)seek:(long)time
{
    [[FMPlayer sharedInstance]seek:time];

}

- (void)stop
{
    [[FMPlayer sharedInstance]stop];

}

- (void)pause
{
    [[FMPlayer sharedInstance]pause];
}

- (void)resume
{
    [[FMPlayer sharedInstance]resume];

}

- (void)togglePause
{
    [[FMPlayer sharedInstance]togglePause];
}

#pragma mark - FMPlayListActionProtocol

- (void)removeList:(NSArray *)sourceList
{
    if (sourceList==nil||sourceList.count==0) {
        NSLog(@"----删除音频列表不能为空-----");
        return;
    }
    @synchronized(_playIdList)
    {
        FMAudioInfo *nowInfo=(FMAudioInfo *)[_playList objectAtIndex:_playIndex];
        __block long nowAudioId=nowInfo.audioId;
        __block BOOL isRemoved=NO;
        [sourceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([_playIdList containsObject:obj]) {
                isRemoved=YES;
                if ([obj isEqualToNumber:[NSNumber numberWithLong:nowAudioId]]) {
                    if ([_playIdList indexOfObject:obj]<(_playIdList.count-1)) {
                        nowAudioId=[[_playIdList objectAtIndex:([_playIdList indexOfObject:obj]+1)]longValue];
                    }
                    else
                    {
                        if ([_playIdList indexOfObject:obj]>0) {
                            nowAudioId=[[_playIdList objectAtIndex:([_playIdList indexOfObject:obj]-1)]longValue];
                        }
                        else
                        {
                            nowAudioId=0;
                        }
                        
                    }
                }
                NSInteger removeIndex=[_playIdList indexOfObject:obj];
                [_playIdList removeObjectAtIndex:removeIndex];
                [_playList removeObjectAtIndex:removeIndex];
                NSLog(@"-----%@————————音频移除成功",obj);
                
            }
            else
            {
                NSLog(@"-----%@————————音频不存在，移除失败",obj);
                
            }
        }];
        
        if (isRemoved) {
            NSInteger nowIndex=0;
            if (nowAudioId!=0) {
                nowIndex=[_playIdList indexOfObject:[NSNumber numberWithLong:nowAudioId]];
            }
            
            if (_playIndex!=nowIndex) {
                _playIndex=nowIndex;
            }
            
            if (_delegate&&[_delegate respondsToSelector:@selector(didChangePlayList:index:changeType:)]) {
                [_delegate didChangePlayList:_playIdList index:_playIndex changeType:PlayListChangeTypeList];
            }
        }
    
    }
   


}

- (void)updateList:(NSArray *)sourceList
{
    if (sourceList==nil||sourceList.count==0) {
        NSLog(@"----删除音频列表不能为空-----");
        return;
    }
    @synchronized(_playIdList)
    {
        [sourceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FMAudioInfo *audioInfo=(FMAudioInfo *)obj;
            if ([_playIdList containsObject:[NSNumber numberWithLong:audioInfo.audioId]]) {
                NSInteger updateIndex=[_playIdList indexOfObject:[NSNumber numberWithLong:audioInfo.audioId]];
                [_playList replaceObjectAtIndex:updateIndex withObject:obj];
                NSLog(@"-----%ld————————音频更新成功",audioInfo.audioId);
            }
            else
            {
                [_playList addObject:audioInfo];
                [_playIdList addObject:[NSNumber numberWithLong:audioInfo.audioId]];
                NSLog(@"-----%ld————————音频添加成功---",audioInfo.audioId);
                
            }
        }];
        
            if (_delegate&&[_delegate respondsToSelector:@selector(didChangePlayList:index:changeType:)]) {
                [_delegate didChangePlayList:_playIdList index:_playIndex changeType:PlayListChangeTypeList];
            }
        
    }
    
}

//增加方法，随机听列表加载时，允许数据重复
- (void)updateListWithRepeatedItem:(NSArray *)sourceList
{
    if (sourceList==nil||sourceList.count==0) {
        NSLog(@"----删除音频列表不能为空-----");
        return;
    }
    @synchronized(_playIdList)
    {
        [sourceList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FMAudioInfo *audioInfo=(FMAudioInfo *)obj;
            /*BBH: 不判断重复，播放服务器数据*/
            [_playList addObject:audioInfo];
            [_playIdList addObject:[NSNumber numberWithLong:audioInfo.audioId]];
            NSLog(@"-----%ld————————音频添加成功---",audioInfo.audioId);
        }];
        
        if (_delegate&&[_delegate respondsToSelector:@selector(didChangePlayList:index:changeType:)]) {
            [_delegate didChangePlayList:_playIdList index:_playIndex changeType:PlayListChangeTypeList];
        }
    }
}

-(void)resetList
{
    @synchronized(_playIdList)
    {
        if (_playList.count!=0) {
            [_playIdList removeAllObjects];
            [_playList removeAllObjects];
        }

    }
}
- (long)getPlayingIndex
{
    return _playIndex;
}

- (long)getPlayingId{
    if (_playList.count>_playIndex) {
        FMAudioInfo *playAudioInfo=(FMAudioInfo *)[_playList objectAtIndex:_playIndex];
        return playAudioInfo.phId;
    }
    return -1;
}


- (long)getPlayListCount
{
    return _playIdList.count;
}
- (long)getPlayAudioIdForIndex:(long)index
{
    if (index<_playIdList.count) {
        FMAudioInfo *info=[_playList objectAtIndex:index];
        return info.audioId;
    }
    return 0;
}


@end
