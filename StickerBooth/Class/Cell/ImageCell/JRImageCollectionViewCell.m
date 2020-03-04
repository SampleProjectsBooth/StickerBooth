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
#import "JRConfigTool.h"

@interface JRImageCollectionViewCell ()

@property (weak, nonatomic) LFMEGifView *imageView;

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
    self.imageView.image = [JRConfigTool shareInstance].normalImage;
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

- (UIImage *)image
{
    return self.imageView.image;
}

#pragma mark - Public Methods
- (void)setCellData:(id)data
{
    [super setCellData:data];
    __block JRStickerContent *obj = (JRStickerContent *)data;
    if (obj.state == JRStickerContentState_Fail) {
        self.imageView.image = [JRConfigTool shareInstance].failureImage;
        return;
    }
    id itemData = obj.content;
    __weak typeof(self) weakSelf = self;
    if ([itemData isKindOfClass:[NSURL class]]) {
        NSURL *dataURL = (NSURL *)itemData;
        if ([[[dataURL scheme] lowercaseString] isEqualToString:@"file"]) {
            NSData *localData = [NSData dataWithContentsOfURL:dataURL];
            if (localData) {
                obj.state = JRStickerContentState_Success;
                self.imageView.data = localData;
            } else {
                obj.state = JRStickerContentState_Fail;
                self.imageView.image = [JRConfigTool shareInstance].failureImage;
            }
        } else {
            NSData *httplocalData = [self dataFromCacheWithURL:dataURL];
            if (httplocalData) {
                obj.state = JRStickerContentState_Success;
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
                        obj.state = JRStickerContentState_Fail;
                        self.imageView.image = [JRConfigTool shareInstance].failureImage;
                    } else {
                        obj.state = JRStickerContentState_Success;
                        weakSelf.progressView.hidden = YES;
                        weakSelf.imageView.data = downloadData;
                    }
                }
                
            }];
        }
    } else if ([itemData isKindOfClass:[PHAsset class]]){
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
        __weak typeof(self) weakSelf = self;
        
        [JRPHAssetManager jr_GetPhotoWithAsset:itemData completion:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info, BOOL isDegraded) {
            weakSelf.progressView.hidden = YES;
            if (!result) {
                obj.state = JRStickerContentState_Fail;
                self.imageView.image = [JRConfigTool shareInstance].failureImage;
            } else {
                obj.state = JRStickerContentState_Success;
                weakSelf.imageView.image = result;
            }
        } progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
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
    self.imageView.image = [JRConfigTool shareInstance].normalImage;

    LFStickerProgressView *view1 = [[LFStickerProgressView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:view1];
    [self.contentView bringSubviewToFront:view1];
    self.progressView = view1;    
}


@end
