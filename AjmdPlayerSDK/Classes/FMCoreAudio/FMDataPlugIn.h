//
//  FMDataPlugIn.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMDataPlugIn : NSObject

@property (nonatomic,strong,readonly)NSString *format;

-(NSString *)format;

-(NSArray *)pluginHandleData:(NSArray *)data;

@end
