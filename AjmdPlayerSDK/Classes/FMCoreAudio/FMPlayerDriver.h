//
//  FMPlayerDriver.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMPlayerActionProtocol.h"
#import "FMDataProtocol.h"
#import "FMPlayerListActionProtocol.h"
#import "FMServicePlugIn.h"

@interface FMPlayerDriver : NSObject<FMPlayerActionProtocol,FMDataProtocol,FMPlayerListActionProtocol>

+ (id)sharedInstance;

- (NSArray *)getFormats;

- (NSArray *)getServicePlugInNames;

-(void)previous;

-(void)next;

-(void)beAudioActivate;

-(void)adaptDataToPlay:(NSArray *)data format:(NSString *)format completed:(void(^)(NSArray *list))block;

-(long)getDefaultAudioIdforUrl:(NSString *)url;

-(void)registerServicePlugInClass:(FMServicePlugIn *)plugInObj;

-(void)unRegisterServicePlugInClass:(FMServicePlugIn *)plugInObj;

@end
