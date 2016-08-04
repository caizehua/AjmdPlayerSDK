//
//  FMServicePlugIn.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPlayerManager.h"
#import "FMPlayerManagerProtocol.h"
@class PlayStatus;

@interface FMServicePlugIn : NSObject<FMPlayerManagerProtocol>

@property (nonatomic,strong)NSString *serviceName;

-(NSString *)serviceName;

@end
