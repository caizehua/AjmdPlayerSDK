//
//  FMDataPluginBase.m
//  FMCoreAudio
//
//  Created by ERC on 15/8/11.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "FMDataPluginBase.h"
#import "FMAudioInfo.h"
@implementation FMDataPluginBase

-(NSArray *)pluginHandleData:(NSArray *)data
{
    __block NSMutableArray *handleList=[NSMutableArray arrayWithCapacity:0];
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            FMAudioInfo *info=[[FMAudioInfo alloc]init];
            info.sourceURL=[obj objectForKey:kPlayUrlKey];
            NSString *skipTime=[obj objectForKey:kSkipTimeKey];
            if (skipTime) {
                info.skipTime=[skipTime intValue];
            }
            else
            {
                info.skipTime=0;
            }
            NSString *audioId=[obj objectForKey:kAudioIdKey];
            if (audioId) {
                info.audioId=[audioId intValue];
            }
            else
            {
                info.audioId=[FMAudioInfo createAudioId:info.sourceURL];
            }
            
            NSString *phId=[obj objectForKey:kPhIdKey];
            if (phId) {
                info.audioId=[phId intValue];
            }
            
            //player stat, start
            //fix 禅道1949 播放下载的音频，闪退
            info.programId =[[obj objectForKey:@"programId"]integerValue];
            //player stat, end
            
            [handleList addObject:info];
        }
    }];

    return handleList;
}

-(NSString *)format
{
    return kDataPlugInBase;
}
@end
