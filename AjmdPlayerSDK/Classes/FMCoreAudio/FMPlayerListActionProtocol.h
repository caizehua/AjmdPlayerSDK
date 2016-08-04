//
//  FMPlayerListActionProtocol.h
//  FMCoreAudio
//
//  Created by ERC on 15/8/11.
//  Copyright (c) 2015年 xgj. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol FMPlayerListActionProtocol <NSObject>

- (void)removeList:(NSArray *)sourceList;

- (void)updateList:(NSArray *)sourceList;

- (void)updateListWithRepeatedItem:(NSArray *)sourceList;

- (void)resetList;

@end
