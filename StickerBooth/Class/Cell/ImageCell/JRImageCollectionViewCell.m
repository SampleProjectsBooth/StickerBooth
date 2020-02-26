//
//  JRImageCollectionViewCell.m
//  gifDemo
//
//  Created by djr on 2020/2/25.
//  Copyright © 2020 djr. All rights reserved.
//

#import "JRImageCollectionViewCell.h"
#import "LFDownloadManager.h"
#import "LFStickerProgressView.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "JRDataStateManager.h"

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
    self.imageView.data = nil;
    self.progressView.hidden = NO;
}


#pragma mark - Public Methods
- (void)setCellData:(id)data indexPath:(nonnull NSIndexPath *)indexPath
{
    [super setCellData:data];
    if ([[JRDataStateManager shareInstance] stateTypeForIndex:indexPath.row] == JRDataState_Fail) {
        self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
        return;
    }
    self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"success" ofType:@"png"]];
    self.progressView.hidden = YES;

    if ([data isKindOfClass:[NSURL class]]) {
        NSURL *dataURL = (NSURL *)data;
        if ([[[dataURL scheme] lowercaseString] isEqualToString:@"file"]) {
            NSData *localData = [NSData dataWithContentsOfURL:dataURL];
            if (localData) {
                [[JRDataStateManager shareInstance] changeState:indexPath.row stateType:JRDataState_Success];
                self.imageView.data = [NSData dataWithContentsOfURL:dataURL];
            } else {
                [[JRDataStateManager shareInstance] changeState:indexPath.row stateType:JRDataState_Fail];
                self.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
            }
        } else {
            self.progressView.hidden = NO;
            self.progressView.progress = 0;
            __weak typeof(self) weakSelf = self;
            [[LFDownloadManager shareLFDownloadManager] lf_downloadURL:dataURL progress:^(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite, NSURL *URL) {
                if ([URL.absoluteString isEqualToString:dataURL.absoluteString]) {
                    float progess = totalBytesWritten*1.00f/totalBytesExpectedToWrite*1.00f;
                    weakSelf.progressView.progress = progess;
                }
            } completion:^(NSData *downloadData, NSError *error, NSURL *URL) {
                if ([URL.absoluteString isEqualToString:dataURL.absoluteString]) {
                    if (error || downloadData == nil) {
                        [[JRDataStateManager shareInstance] changeState:indexPath.row stateType:JRDataState_Fail];
                        weakSelf.imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"]];
                    } else {
                        [[JRDataStateManager shareInstance] changeState:indexPath.row stateType:JRDataState_Success];
                        weakSelf.progressView.hidden = YES;
                        weakSelf.imageView.data = downloadData;
                    }
                }
            }];
        }
    } else {
        
    }
}

#pragma mark - Private Methods
- (void)_initSubViewAndDataSources
{
    LFMEGifView *imageView = [[LFMEGifView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
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
