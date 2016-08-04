//
//  AudioInfo.m
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "FMAudioInfo.h"

@implementation FMAudioInfo

+(long)createAudioId:(NSString *)url
{
    return[url hash];
}

@end
