//
//  FMDataProtocol.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

@protocol FMDataProtocol <NSObject>

-(void)registerDataPlugInClass:(NSString *)name;

-(void)unRegisterDataPlugInClass:(NSString *)name;

@end
