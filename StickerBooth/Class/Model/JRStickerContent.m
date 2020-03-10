//
//  JRStickerContent.m
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/2/26.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRStickerContent.h"
#import <Photos/Photos.h>

@interface JRStickerContent ()


@end

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

- (JRStickerContentType)type
{
    JRStickerContentType _type = JRStickerContentType_Unknow;
    if ([_content isKindOfClass:[NSURL class]]) {
        NSURL *dataURL = (NSURL *)_content;
        if ([[[dataURL scheme] lowercaseString] isEqualToString:@"file"]) {
            _type = JRStickerContentType_URLForFile;
        } else {
            _type = JRStickerContentType_URLForHttp;
        }
    } else if ([_content isKindOfClass:[PHAsset class]]) {
        _type = JRStickerContentType_PHAsset;
    }
    return _type;
}

@end
