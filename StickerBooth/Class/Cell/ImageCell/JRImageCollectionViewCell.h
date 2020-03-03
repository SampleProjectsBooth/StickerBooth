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

@property (readonly, nonatomic, nonnull) NSData *imageData;

@property (readonly, nonatomic, nonnull) UIImage *image;

- (void)setCellData:(id)data;

- (void)clearData;

@end

NS_ASSUME_NONNULL_END
