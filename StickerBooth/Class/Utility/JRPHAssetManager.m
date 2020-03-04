//
//  JRPHAssetManager.m
//  StickerBooth
//
//  Created by djr on 2020/3/3.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRPHAssetManager.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface JRPHAssetManager ()

@end

@implementation JRPHAssetManager

#pragma mark - Public Methods
+ (BOOL)jr_IsGif:(PHAsset *)asset
{
    BOOL isGif = [[asset valueForKey:@"uniformTypeIdentifier"] isEqualToString:(__bridge NSString*)kUTTypeGIF];
    return isGif;
}

+ (PHImageRequestID)jr_GetPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler {
    if ([asset isKindOfClass:[PHAsset class]]) {
        BOOL isGif = [JRPHAssetManager jr_IsGif:asset];
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init]; option.resizeMode = PHImageRequestOptionsResizeModeFast;
        if (isGif) {
            // GIF图片在系统相册中不能修改，它不存在编辑图或原图的区分。但是个别GIF使用默认的 PHImageRequestOptionsVersionCurrent属性可能仅仅是获取第一帧。
            option.version = PHImageRequestOptionsVersionOriginal;
        }
        return [JRPHAssetManager _jr_getPhotoDataWithAsset:asset option:option isGif:isGif completion:completion progressHandler:progressHandler];
    } else {
        if (completion) completion(nil,nil,NO);
    }
    return 0;
    
}


+ (PHImageRequestID)jr_GetPhotoWithAsset:(PHAsset *)phAsset completion:(void (^)(UIImage *result,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    CGFloat photoWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
    CGFloat pixelWidth = photoWidth * 2.f;
    CGFloat pixelHeight = pixelWidth / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    // 修复获取图片时出现的瞬间内存过高问题
    // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && result) {
            if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        } else
            // Download image from iCloud / 从iCloud下载图片
            if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !result) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    if ([NSThread isMainThread]) {
                        if (progressHandler) {
                            progressHandler(progress, error, stop, info);
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (progressHandler) {
                                progressHandler(progress, error, stop, info);
                            }
                        });
                    };
                };
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                }];
            } else {
                if (completion) completion(result,info,[[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            }
    }];
    return imageRequestID;
}


#pragma mark - Private Mehods
+ (PHImageRequestID)_jr_getPhotoDataWithAsset:(id)asset option:(PHImageRequestOptions *)option isGif:(BOOL)isGif completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler
{
    PHImageRequestID imageRequestID = PHInvalidImageRequestID;
    if (@available(iOS 13, *)) {
        imageRequestID = [[PHImageManager defaultManager] requestImageDataAndOrientationForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, CGImagePropertyOrientation orientation, NSDictionary * _Nullable info) {
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && imageData) {
                BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue]; if (completion) completion(imageData,info,isDegraded);
            } else {
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
            }
        }];
    } else {
        imageRequestID = [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option
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
@end

