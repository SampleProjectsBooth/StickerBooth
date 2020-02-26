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

@property (readonly, nonatomic, nonnull) LFMEGifView *imageView;

- (void)setCellData:(id)data indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
