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
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "JRStickerContent.h"

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
        [self getPhotoDataWithAsset:data completion:^(NSData *reslutData, NSDictionary *info, BOOL isDegraded) {
            if (!reslutData) {
                item.state = JRStickerContentState_Fail;
                self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
            } else {
                item.state = JRStickerContentState_Success;
                weakSelf.imageView.data = reslutData;
            }
        } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            
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

- (PHImageRequestID)getPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler {
    if ([asset isKindOfClass:[PHAsset class]]) {
        BOOL isGif = [[asset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString*)kUTTypeGIF];
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init]; option.resizeMode = PHImageRequestOptionsResizeModeFast;
        if (isGif) {
            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的 PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
            option.version = PHImageRequestOptionsVersionOriginal;
        }
        PHImageRequestID imageRequestID = PHInvalidImageRequestID; if (@available(iOS 13, *)) {
            [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && imageData) {
                    BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue]; if (completion) completion(imageData,info,isDegraded);
                }
                else
                    // Download image from iCloud / 从iCloud下载图片
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init]; if (progressHandler) {
                            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                                if ([NSThread isMainThread]) {
                                    progressHandler(progress, error, stop, info);
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        progressHandler(progress, error, stop, info);
                                    });
                                };
                            };
                        }
                        options.networkAccessAllowed = YES;
                        options.resizeMode = PHImageRequestOptionsResizeModeFast;
                        if (isGif) {
                            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默 认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
                            options.version = PHImageRequestOptionsVersionOriginal;
                        }
                        [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
                            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                            if (completion) completion(imageData,info,isDegraded);
                        }];
                    } else {
                        if (completion) completion(imageData,info,[[info
                                                                    objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
            }];
        } else {
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option
                                                        resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                if (downloadFinined && imageData) {
                    BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (completion) completion(imageData,info,isDegraded);
                } else
                    // Download image from iCloud / 从iCloud下载图片
                    if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init]; if (progressHandler) {
                            options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                                if ([NSThread isMainThread]) {
                                    progressHandler(progress, error, stop, info);
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        progressHandler(progress, error, stop, info);
                                    });
                                };
                            };
                        }
                        options.networkAccessAllowed = YES;
                        options.resizeMode = PHImageRequestOptionsResizeModeFast;
                        if (isGif) {
                            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用 默认的PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
                            options.version = PHImageRequestOptionsVersionOriginal;
                            
                        }
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            
                            BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                            if (completion) completion(imageData,info,isDegraded);
                            
                        }];
                    } else {
                        if (completion) completion(imageData,info,[[info
                                                                    objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    }
            }];
            
        }
        return imageRequestID;
    }
    else {
        if (completion) completion(nil,nil,NO);
    }
    return 0;
    
}


@end
