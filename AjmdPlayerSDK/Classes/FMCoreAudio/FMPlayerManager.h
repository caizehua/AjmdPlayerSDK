//
//  FMPlayerManager.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPlayerActionProtocol.h"
#import "FMPlayerListActionProtocol.h"
#import "FMPlayerManagerProtocol.h"


@interface FMPlayerManager : NSObject<FMPlayerActionProtocol,FMPlayerListActionProtocol>

@property(nonatomic,weak)id<FMPlayerManagerProtocol>delegate;

+ (id)sharedInstance;

- (long)getPlayingIndex;

- (long)getPlayingId;

- (long)getPlayListCount;

- (long)getPlayAudioIdForIndex:(long)index;


@end
