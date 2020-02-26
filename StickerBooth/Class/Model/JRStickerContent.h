//
//  JRStickerContent.h
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/2/26.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, JRStickerContentState) {
    JRStickerContentState_None = 0,
    JRStickerContentState_Success,
    JRStickerContentState_Fail,
};

@interface JRStickerContent : NSObject

/** 内容 */
@property (nonatomic, strong) id content;
/** 状态 */
@property (nonatomic, assign) JRStickerContentState state;

+ (instancetype)stickerContentWithContent:(id)content;
- (instancetype)initWithContent:(id)content;

@end

NS_ASSUME_NONNULL_END