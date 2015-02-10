//
//  iosfilters.h
//  iosfilters
//
//  Created by Azer Bulbul on 10/13/14.
//  Copyright (c) 2014 azer. All rights reserved.
//

#ifdef __OBJC__
    #define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#endif

#import "FlashRuntimeExtensions.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreImage/CoreImage.h>

@interface iosfilters : NSObject

+ (iosfilters *)sharedInstance;

@property (nonatomic, readonly) CIContext *cicontext;

+ (NSDictionary *)  freObjeToDictWithKeys:  (FREObject)     keys values:(FREObject)vals;

-(void)createSigContext;

-(void)callCoreImageFilterWithArgv:(FREObject*)argv argc:(uint32_t)argc;

@end


DEFINE_ANE_FUNCTION(CreateSigContext);
DEFINE_ANE_FUNCTION(CoreImageFilterRequest);


void FiltersContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                               uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void FiltersContextFinalizer(FREContext ctx);

void FiltersExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                           FREContextFinalizer* ctxFinalizerToSet);

void FiltersExtFinalizer(void* extData);