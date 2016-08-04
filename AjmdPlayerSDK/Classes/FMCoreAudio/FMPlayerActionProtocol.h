//
//  FMPlayerActions.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PlayModel) {
    PlayModelOnce   =   0,
    PlayModelOrder,
    PlayModelAllRepeat,
    PlayModelShuffle,
    PlayModelRepeatOnce,
};

typedef NS_ENUM(NSUInteger, PlayIndexType) {
    PlayIndexTypeAudioId = 0,
    PlayIndexTypeOrderId,
};


@protocol FMPlayerActionProtocol <NSObject>

- (void)setModel:(PlayModel)model;
-(void)playforType:(PlayIndexType)type index:(long)indexId;
- (int)getFileType;
- (long)getFileDuration;
- (int)getFMLiveState;
- (void)setLiveDuration:(long)duration;
- (long)getLiveDuration;
- (void)setLiveTotalDuration:(long)duration;
- (void)seek:(long)time;
- (void)stop;
- (void)pause;
- (void)resume;
- (void)togglePause;

@end
