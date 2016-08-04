//
//  AudioInfo.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMAudioInfo : NSObject

@property (nonatomic,strong)NSString *sourceURL;

@property (nonatomic,assign)long skipTime;

@property (nonatomic,assign)long audioId;

@property (nonatomic) long phId;

@property (nonatomic,assign)long programId; //player stat, add

@property (nonatomic,copy)NSString *did;

+(long)createAudioId:(NSString *)url;

@end
