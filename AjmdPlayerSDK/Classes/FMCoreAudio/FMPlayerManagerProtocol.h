//
//  FMPlayerManagerProtocol.h
//  FMPlayerDemo
//
//  Created by ERC on 15/8/17.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "AjmdPlayer.h"

typedef NS_ENUM(NSUInteger, PlayListChangeType) {
    PlayListChangeTypeList=0,
    PlayListChangeTypeIndex,
};

@protocol FMPlayerManagerProtocol <NSObject>

-(void)didChangePlayState:(PlayStatus *)status;

-(void)didChangePlayList:(NSArray *)playList index:(NSUInteger)index changeType:(PlayListChangeType)type;

@end
