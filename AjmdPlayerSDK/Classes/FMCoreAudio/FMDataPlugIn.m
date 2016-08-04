//
//  FMDataPlugIn.m
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "FMDataPlugIn.h"
#import "FMAudioInfo.h"
@implementation FMDataPlugIn

-(NSArray *)pluginHandleData:(NSArray *)data
{
    NSAssert(1, @"---若使用解析插件请重载此函数并注册--");
    return @[];
}

-(NSString *)format
{
    NSAssert(1, @"---若使用解析插件请重载此函数并注册---");
    return @"";
}

@end
