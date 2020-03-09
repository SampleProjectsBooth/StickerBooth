//
//  JRDataImageView.m
//  StickerBooth
//
//  Created by djr on 2020/3/4.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRDataImageView.h"
#import "LFImageCoder.h"

inline static UIImageOrientation JRMEGifView_UIImageOrientationFromEXIFValue(NSInteger value) {
    switch (value) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

@interface JRDataImageView ()

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation JRDataImageView

@synthesize isGif = _isGif;

- (void)dealloc
{
    _queue = nil;
}

- (void)jr_dataForImage:(nullable NSData *)data
{
    _isGif = NO;
    if (data) {
        CGImageSourceRef _imgSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
        if (_imgSourceRef) {
            _isGif = CGImageSourceGetCount(_imgSourceRef) > 1;
            CGSize size = self.frame.size;
            UIViewContentMode mode = self.contentMode;
            if (!self.queue) {
                self.queue = dispatch_queue_create("com.JRDataIamgeView.queue", DISPATCH_QUEUE_SERIAL);
            }
            __weak typeof(self) weakSelf = self;
            dispatch_async(self.queue, ^{
                if (weakSelf != nil) {
                    UIImageOrientation imgOrientation = UIImageOrientationUp;
                    //exifInfo 包含了很多信息,有兴趣的可以打印看看,我们只需要Orientation这个字段
                    CFDictionaryRef exifInfo = CGImageSourceCopyPropertiesAtIndex(_imgSourceRef, 0,NULL);
                    //判断Orientation这个字段,如果图片经过PS等处理,exif信息可能会丢失
                    if(CFDictionaryContainsKey(exifInfo, kCGImagePropertyOrientation)){
                        CFNumberRef orientation = CFDictionaryGetValue(exifInfo, kCGImagePropertyOrientation);
                        NSInteger orientationValue = 0;
                        CFNumberGetValue(orientation, kCFNumberIntType, &orientationValue);
                        imgOrientation = JRMEGifView_UIImageOrientationFromEXIFValue(orientationValue);
                    }
                    CFRelease(exifInfo);
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imgSourceRef, 0, NULL);
                    CGImageRef decodeImageRef = LFIC_CGImageScaleDecodedFromCopy(imageRef, size, mode, imgOrientation);
                    if (imageRef) {
                        CGImageRelease(imageRef);
                    }
                    CFRelease(_imgSourceRef);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.image = [UIImage imageWithCGImage:decodeImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                        if (decodeImageRef) {
                            CGImageRelease(decodeImageRef);
                        }
                    });
                }
            });
        }
    } else {
        self.image = nil;
    }
}

- (BOOL)isGif
{
    return _isGif;
}

@end
