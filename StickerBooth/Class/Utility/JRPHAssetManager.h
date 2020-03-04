//
//  JRPHAssetManager.h
//  StickerBooth
//
//  Created by djr on 2020/3/3.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface JRPHAssetManager : NSObject

+ (BOOL)jr_IsGif:(PHAsset *)asset;

+ (PHImageRequestID)jr_GetPhotoDataWithAsset:(id)asset completion:(void (^)(NSData *data,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

+ (PHImageRequestID)jr_GetPhotoWithAsset:(PHAsset *)phAsset completion:(void (^)(UIImage *result,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

@end

NS_ASSUME_NONNULL_END
