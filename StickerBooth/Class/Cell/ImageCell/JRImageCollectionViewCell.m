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
#import "JRDataImageView.h"


CGFloat const JR_kVideoBoomHeight = 25.f;
@interface JRImageCollectionViewCell ()

@property (weak, nonatomic) JRDataImageView *imageView;

@property (weak, nonatomic) LFStickerProgressView *progressView;

@property (weak, nonatomic) UIView *bottomView;

@property (weak, nonatomic) UILabel *bottomLab;

@property (strong, nonatomic) CAShapeLayer *maskLayer;

@property (nonatomic, strong) dispatch_queue_t queue;

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
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - JR_kVideoBoomHeight, CGRectGetWidth(self.contentView.bounds), JR_kVideoBoomHeight);
    self.bottomLab.frame = CGRectInset(self.bottomView.bounds, 2.5f, 5.f);
    self.maskLayer.frame = CGRectInset(self.contentView.bounds, -5.f, -5.f);

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
    _queue = nil;
}

- (void)jr_getImageData:(void(^)(NSData *data))completeBlock
{
    JRStickerContent *obj = (JRStickerContent *)self.cellData;
    if (obj.state == JRStickerContentState_Fail) {
        if (completeBlock) {
            completeBlock(nil);
        }
        return;
    }
    id itemData = obj.content;
    if (obj.state == JRStickerContentState_Success) {
        if ([itemData isKindOfClass:[NSURL class]]) {
            __weak typeof(self) weakSelf = self;
            NSURL *dataURL = (NSURL *)itemData;
            if (!self.queue) {
                self.queue = dispatch_queue_create("com.JRImageCollectionViewCell.queue", DISPATCH_QUEUE_SERIAL);
            }
            dispatch_async(self.queue, ^{
                NSData *resultData = nil;
                if ([[[dataURL scheme] lowercaseString] isEqualToString:@"file"]) {
                    resultData = [NSData dataWithContentsOfURL:dataURL];
                } else {
                    resultData = [weakSelf dataFromCacheWithURL:dataURL];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completeBlock) {
                        completeBlock(resultData);
                    }
                });
            });
        } else if ([itemData isKindOfClass:[PHAsset class]]) {
            [JRPHAssetManager jr_GetPhotoDataWithAsset:itemData completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info, BOOL isDegraded) {
                if (completeBlock) {
                    completeBlock(data);
                }
            } progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull info) {
                
            }];
        }
    }
}

- (UIImage *)image
{
    return self.imageView.image;
}

#pragma mark - Public Methods
- (void)setCellData:(id)data
{
    [super setCellData:data];
    self.bottomView.hidden = YES;
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
                [self.imageView jr_dataForImage:localData];
                self.bottomView.hidden =  !self.imageView.isGif;
            } else {
                obj.state = JRStickerContentState_Fail;
                self.imageView.image = [JRConfigTool shareInstance].failureImage;
            }
        } else {
            NSData *httplocalData = [self dataFromCacheWithURL:dataURL];
            if (httplocalData) {
                obj.state = JRStickerContentState_Success;
                [self.imageView jr_dataForImage:httplocalData];
                self.bottomView.hidden =  !self.imageView.isGif;
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
                    weakSelf.progressView.hidden = YES;
                    if (error || downloadData == nil) {
                        obj.state = JRStickerContentState_Fail;
                        weakSelf.imageView.image = [JRConfigTool shareInstance].failureImage;
                    } else {
                        obj.state = JRStickerContentState_Success;
                        [weakSelf.imageView jr_dataForImage:downloadData];
                        weakSelf.bottomView.hidden =  !weakSelf.imageView.isGif;
                    }
                }
                
            }];
        }
    } else if ([itemData isKindOfClass:[PHAsset class]]){
        self.progressView.hidden = NO;
        self.progressView.progress = 0.f;
        self.bottomView.hidden = ![JRPHAssetManager jr_IsGif:itemData];
        __weak typeof(self) weakSelf = self;
        [JRPHAssetManager jr_GetPhotoWithAsset:itemData completion:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info, BOOL isDegraded) {
            weakSelf.progressView.hidden = YES;
            if (!result) {
                obj.state = JRStickerContentState_Fail;
                weakSelf.imageView.image = [JRConfigTool shareInstance].failureImage;
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
    [self lf_downloadCancel];
}

- (void)showMaskLayer:(BOOL)isShow
{
    self.maskLayer.hidden = !isShow;
}

#pragma mark - Private Methods
- (void)_initSubViewAndDataSources
{
    self.contentView.backgroundColor = [UIColor clearColor];

    JRDataImageView *imageView = [[JRDataImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - JR_kVideoBoomHeight, CGRectGetWidth(self.contentView.bounds), JR_kVideoBoomHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    self.imageView.image = [JRConfigTool shareInstance].normalImage;

    LFStickerProgressView *view1 = [[LFStickerProgressView alloc] init];
    [self.contentView addSubview:view1];
    [self.contentView bringSubviewToFront:view1];
    self.progressView = view1;
    
    /** 底部状态栏 */
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, self.contentView.frame.size.height - JR_kVideoBoomHeight, self.contentView.frame.size.width, JR_kVideoBoomHeight);
    [self.contentView addSubview:bottomView];
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = bottomView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.0f alpha:.0f] CGColor], (id)[[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor], nil];
    [bottomView.layer insertSublayer:gradientLayer atIndex:0];
    self.bottomView = bottomView;
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectInset(bottomView.bounds, 2.5f, 5.f)];
    lab.textAlignment = NSTextAlignmentRight;
    lab.text = @"GIF";
    lab.textColor = [UIColor whiteColor];
    [self.bottomView addSubview:lab];
    self.bottomLab = lab;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.bounds = CGRectInset(self.contentView.bounds, -5.f, -5.f);
    maskLayer.hidden = YES;
    maskLayer.cornerRadius = 2.5f;
    maskLayer.backgroundColor = [UIColor colorWithWhite:1.f alpha:.5f].CGColor;
    [self.contentView.layer insertSublayer:maskLayer below:self.imageView.layer];
    self.maskLayer = maskLayer;
}


@end
