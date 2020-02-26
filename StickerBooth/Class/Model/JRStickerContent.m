//
//  JRStickerContent.m
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/2/26.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRStickerContent.h"

@implementation JRStickerContent

+ (instancetype)stickerContentWithContent:(id)content
{
    return [[self alloc] initWithContent:content];
}
- (instancetype)initWithContent:(id)content
{
    self = [super init];
    if (self) {
        _content = content;
        _state = JRStickerContentState_None;
    }
    return self;
}

@end
