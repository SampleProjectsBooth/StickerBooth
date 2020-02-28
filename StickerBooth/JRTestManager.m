//
//  JRTestManager.m
//  StickerBooth
//
//  Created by djr on 2020/2/28.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRTestManager.h"

@implementation JRTestManager

+ (instancetype)shareInstance
{
    static JRTestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JRTestManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context = [NSMutableArray arrayWithCapacity:1];
    } return self;
}


@end
