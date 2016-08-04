//
//  FMDataManager.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDataProtocol.h"

@interface FMDataManager : NSObject<FMDataProtocol>

+ (id)sharedInstance;

@property (nonatomic,strong,readonly)NSMutableArray *formats;

@property (nonatomic,strong,readonly)NSMutableArray *dataPlugIns;

-(void)managerHandleData:(NSArray *)data format:(NSString *)format completed:(void(^)(NSArray *list))block;

-(NSArray *)getDetailListInfo:(NSArray *)idList;

@end
