//
//  JRPHAssetManager.m
//  StickerBooth
//
//  Created by djr on 2020/3/3.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRPHAssetManager.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface JRPHAssetManager ()

@end

@implementation JRPHAssetManager



+ (NSArray <PHAsset *>*)jr_GetAllPhotos
{
    NSMutableArray *stickers = [NSMutableArray arrayWithCapacity:1];
    if (@available(iOS 8.0, *)){
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        PHFetchResult *fetchResult = nil;
        for (PHAssetCollection *collection in smartAlbums) {
            // 有可能是PHCollectionList类的的对象，过滤掉
            if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
            fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            break;
        }
        
        for (PHAsset *asset in fetchResult) {
            [stickers addObject:asset];
        }
    }
    return [stickers copy];
}

+ (PHImageRequestID)jr_GetPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler {
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

