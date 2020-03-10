//
//  JRStickerContent+JRGetData.m
//  StickerBooth
//
//  Created by djr on 2020/3/10.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRStickerContent+JRGetData.h"
#import "JRConfigTool.h"
#import "LFDownloadManager.h"
#import "JRPHAssetManager.h"

@implementation JRStickerContent (JRGetData)

- (void)jr_getData:(nullable void(^)(NSData * _Nullable data))completeBlock
{
    if (completeBlock) {
        [self jr_getData:^(NSData *data) {
            completeBlock(data);
        } imageBlock:nil];
    }
}

- (void)jr_getImage:(nullable void(^)(UIImage * _Nullable image))completeBlock
{
    if (completeBlock) {
        [self jr_getData:nil imageBlock:^(UIImage *image) {
            completeBlock(image);
        }];
    }
}

- (void)jr_getData:(nullable void(^)(NSData * _Nullable data))completeBlock imageBlock:(nullable void(^)(UIImage * _Nullable image))imageBlock
{
    if (self.state == JRStickerContentState_Success) {
        switch (self.type) {
            case JRStickerContentType_PHAsset:
            {
                if (completeBlock) {
                    [JRPHAssetManager jr_GetPhotoDataWithAsset:self.content completion:^(NSData * _Nonnull data, NSDictionary * _Nonnull info, BOOL isDegraded) {
                        completeBlock(data);
                    } progressHandler:nil];
                }
                if (imageBlock) {
                    [JRPHAssetManager jr_GetPhotoWithAsset:self.content photoWidth:CGRectGetWidth([UIScreen mainScreen].bounds) completion:^(UIImage * _Nonnull result, NSDictionary * _Nonnull info, BOOL isDegraded) {
                        imageBlock(result);
                    } progressHandler:nil];
                }
            }
                break;
            case JRStickerContentType_URLForHttp:
            case JRStickerContentType_URLForFile:
            {
                dispatch_queue_t queue = [JRConfigTool shareInstance].concurrentQueue;
                dispatch_async(queue, ^{
                    NSData *resultData = nil;
                    if (self.type == JRStickerContentType_URLForHttp) {
                        resultData = [[LFDownloadManager shareLFDownloadManager] dataFromSandboxWithURL:self.content];
                    } else if (self.type == JRStickerContentType_URLForFile) {
                        resultData = [NSData dataWithContentsOfURL:self.content];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completeBlock) {
                            completeBlock(resultData);
                        }
                        if (imageBlock) {
                            imageBlock([UIImage imageWithData:resultData]);
                        }
                    });
                });
            }
                break;
            default:
            {
                if (completeBlock) {
                    completeBlock(nil);
                }
                if (imageBlock) {
                    imageBlock(nil);
                }
            }
                break;
        }
    } else {
        if (completeBlock) {
            completeBlock(nil);
        }
        if (imageBlock) {
            imageBlock(nil);
        }
    }
}

@end
