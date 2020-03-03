//
//  JRImageCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/25.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRImageCollectionViewCell.h"
#import "UIView+LFDownloadManager.h"
#import "LFStickerProgressView.h"
#import "JRStickerContent.h"
#import "JRPHAssetManager.h"

@interface JRImageCollectionViewCell ()

@property (strong, nonatomic) LFMEGifView *imageView;

@property (weak, nonatomic) LFStickerProgressView *progressView;

@property (weak, nonatomic) id item;

@end

@implementation JRImageCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _initSubViewAndDataSources];
    } return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViewAndDataSources];
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    self.progressView.center = self.contentView.center;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"success" ofType:@"png"]];
    self.progressView.progress = 0;
    self.progressView.hidden = YES;
}

- (void)dealloc
{
    [self.imageView setData:nil];
}

- (NSData *)imageData
{
    return self.imageView.data;
}

#pragma mark - Public Methods
- (void)setCellData:(JRStickerContent *)item
{
    [super setCellData:item];
    if (item.state == JRStickerContentState_Fail) {
        self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
        return;
    }
    id data = item.content;
    __weak typeof(self) weakSelf = self;
    if ([data isKindOfClass:[NSURL class]]) {
        NSURL *dataURL = (NSURL *)data;
        if ([[[dataURL scheme] lowercaseString] isEqualToString:@"file"]) {
            NSData *localData = [NSData dataWithContentsOfURL:dataURL];
            if (localData) {
                item.state = JRStickerContentState_Success;
                self.imageView.data = localData;
            } else {
                item.state = JRStickerContentState_Fail;
                self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
            }
        } else {
            NSData *httplocalData = [self dataFromCacheWithURL:dataURL];
            if (httplocalData) {
                item.state = JRStickerContentState_Success;
                self.imageView.data = httplocalData;
                return;
            }
            self.progressView.hidden = NO;
            self.progressView.progress = 0.f;
            [self lf_downloadImageWithURL:dataURL progress:^(CGFloat progress, NSURL * _Nonnull URL) {
                if ([URL.absoluteString isEqualToString:dataURL.absoluteString]) {
                    weakSelf.progressView.progress = progress;
                }
            } completed:^(NSData * _Nonnull downloadData, NSError * _Nonnull error, NSURL * _Nonnull URL) {
                if ([URL.absoluteString isEqualToString:dataURL.absoluteString]) {
                    if (error || downloadData == nil) {
                        item.state = JRStickerContentState_Fail;
                        weakSelf.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
                    } else {
                        item.state = JRStickerContentState_Success;
                        weakSelf.progressView.hidden = YES;
                        weakSelf.imageView.data = downloadData;
                    }
                }
                
            }];
        }
    } else {
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
        __weak typeof(self) weakSelf = self;
        [JRPHAssetManager jr_GetPhotoDataWithAsset:data completion:^(NSData *reslutData, NSDictionary *info, BOOL isDegraded) {
            weakSelf.progressView.hidden = YES;
            if (!reslutData) {
                item.state = JRStickerContentState_Fail;
                weakSelf.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
            } else {
                item.state = JRStickerContentState_Success;
                weakSelf.imageView.data = reslutData;
            }
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            weakSelf.progressView.progress = progress;
        }];
    }
}

- (void)clearData
{
    self.imageView.data = nil;
    [self lf_downloadCancel];
}
#pragma mark - Private Methods
- (void)_initSubViewAndDataSources
{
    self.contentView.backgroundColor = [UIColor clearColor];

    LFMEGifView *imageView = [[LFMEGifView alloc] initWithFrame:CGRectZero];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"success" ofType:@"png"]];
    
    LFStickerProgressView *view1 = [[LFStickerProgressView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:view1];
    [self.contentView bringSubviewToFront:view1];
    self.progressView = view1;    
}


@end
