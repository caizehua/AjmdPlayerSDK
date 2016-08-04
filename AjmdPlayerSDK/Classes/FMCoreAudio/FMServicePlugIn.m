//
//  FMServicePlugIn.m
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "FMServicePlugIn.h"
#import "AjmdPlayer.h"

@implementation FMServicePlugIn

-(void)didChangePlayState:(PlayStatus *)status
{
    NSAssert(1, @"---若使用服务插件请重载此函数并注册---");

}

-(void)didChangePlayList:(NSArray *)playList index:(NSUInteger)index changeType:(PlayListChangeType)type
{
    NSAssert(1, @"---若使用服务插件请重载此函数并注册---");
}
-(NSString *)serviceName
{
    NSAssert(1, @"---若使用服务插件请重载此函数并注册---");
    return @"";
}


@end
