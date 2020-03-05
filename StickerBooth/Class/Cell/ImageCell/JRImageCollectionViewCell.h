//
//  JRImageCollectionViewCell.h
//  gifDemo
//
//  Created by djr on 2020/2/25.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRBaseCollectionViewCell.h"
#import "LFMEGifView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JRImageCollectionViewCell : JRBaseCollectionViewCell

//@property (copy, nonatomic, nullable) NSData * _Nullable (^imageDataBlock)(void);

@property (readonly, nonatomic, nonnull) UIImage *image;

@property (assign, nonatomic) BOOL longpress;

- (void)setCellData:(nullable id)data;

- (void)clearData;

- (void)jr_getImageData:(void(^)(NSData *data, UIImage *image))completeBlock;

@end

NS_ASSUME_NONNULL_END
