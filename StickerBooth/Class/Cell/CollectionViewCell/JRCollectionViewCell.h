//
//  JRCollectionViewCell.h
//  gifDemo
//
//  Created by djr on 2020/2/19.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol JRCollectionViewDelegate;

@interface JRCollectionViewCell : JRBaseCollectionViewCell

@property (weak, nonatomic) id<JRCollectionViewDelegate>delegate;

- (void)clearData;

@end

@protocol JRCollectionViewDelegate <NSObject>

- (void)didSelectData:(NSData *)data image:(UIImage *)image index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
