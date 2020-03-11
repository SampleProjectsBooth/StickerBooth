//
//  JRStickerHeader.h
//  StickerBooth
//
//  Created by djr on 2020/3/4.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#ifndef JRStickerHeader_h
#define JRStickerHeader_h

// get方法
#define JRSticker_bind_var_getter(varType, varName, target) \
- (varType)varName \
{ \
    return target.varName; \
}

// set方法
#define JRSticker_bind_var_setter(varType, varName, setterName, target) \
- (void)setterName:(varType)varName \
{ \
    [target setterName:varName]; \
}


#define jr_NotSupperGif

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

#endif /* JRStickerHeader_h */
