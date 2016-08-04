//
//  FMDataManager.m
//  FMCoreAudio
//
//  Created by ERC on 15/8/10.
//  Copyright (c) 2015年 xgj. All rights reserved.
//

#import "FMDataManager.h"
#import "FMDataPlugIn.h"
#import "FMPlayerMacros.h"
#import "FMAudioInfo.h"
@interface FMDataManager ()

@property (nonatomic,strong)NSMutableDictionary *infoDict;

@end

@implementation FMDataManager

+ (id)sharedInstance
{
    static FMDataManager *sharedDataManager=nil;
    if (sharedDataManager==nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedDataManager=[[[self class]alloc]init];
        });
    }
    return sharedDataManager;
}
-(id)init
{
    if (self=[super init]) {
        _formats=[NSMutableArray arrayWithCapacity:0];
        _dataPlugIns=[NSMutableArray arrayWithCapacity:0];
        _infoDict=[NSMutableDictionary dictionaryWithCapacity:0];

    }
    return self;
}

-(void)managerHandleData:(NSArray *)data format:(NSString *)format completed:(void(^)(NSArray *list))block
{
    if ([_formats containsObject:format]) {
        [_dataPlugIns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([[(FMDataPlugIn *)obj format]isEqualToString:format]&&[obj respondsToSelector:@selector(pluginHandleData:)]) {
                NSLog(@"---%@格式准备解析...---",format);
                NSArray *handleList=[obj pluginHandleData:data];
                [handleList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[FMAudioInfo class]]) {
                        FMAudioInfo *info=(FMAudioInfo *)obj;
                        [_infoDict setObject:[data objectAtIndex:idx] forKey:[NSNumber numberWithLong:info.audioId]];
                    }
                }];
                if (block) {
                    block(handleList);
                }
            }
        }];
    }
    else
    {
        NSLog(@"---%@格式未注册解析---",format);
    }
    
}



-(NSArray *)getDetailListInfo:(NSArray *)idList;
{
    __block NSMutableArray *detailList=[NSMutableArray array];
    [idList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            if ([_infoDict objectForKey:obj]) {
                [detailList addObject:[_infoDict objectForKey:obj]];
            }
        }
    }];
    return [detailList copy];
}

-(void)registerDataPlugInClass:(NSString *)name
{
    Class DataPlugin=NSClassFromString(name);
    FMDataPlugIn *plugInObj=[[DataPlugin alloc]init];
    if ([_formats containsObject:plugInObj.format]) {
        NSLog(@"--%@格式解析已经存在-----",plugInObj.format);
    }
    else
    {
        [_dataPlugIns addObject:plugInObj];
        [_formats addObject:plugInObj.format];
        NSLog(@"--%@格式解析注册成功-----",plugInObj.format);
    }
    
}

-(void)unRegisterDataPlugInClass:(NSString *)name
{
    Class DataPlugin=NSClassFromString(name);
    FMDataPlugIn *plugInObj=[[DataPlugin alloc]init];
    if ([_formats containsObject:plugInObj.format]) {
        NSInteger plugIndex=[_formats indexOfObject:plugInObj.format];
        [_formats removeObjectAtIndex:plugIndex];
        [_dataPlugIns removeObjectAtIndex:plugIndex];
        NSLog(@"--%@格式解析注销成功-----",plugInObj.format);
    }
    else
    {
        NSLog(@"--%@格式解析不存在-----",plugInObj.format);
    }
}

@end
