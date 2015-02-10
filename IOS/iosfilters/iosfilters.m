//
//  iosfilters.m
//  iosfilters
//
//  Created by Azer Bulbul on 10/13/14.
//  Copyright (c) 2014 azer. All rights reserved.
//

#import "iosfilters.h"
#import "SingletonCIContext.h"

FREContext IOSFiltersCtx = nil;

@implementation iosfilters


static iosfilters *sharedInstance = nil;

@synthesize cicontext = _cicontext;

+ (iosfilters *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [iosfilters sharedInstance];
}

- (id)copy
{
    return self;
}

-(void)createSigContext
{
    
    _cicontext = [SingletonCIContext context];
}

+(NSDictionary *) freObjeToDictWithKeys:(FREObject)keys values:(FREObject)vals
{
    uint32_t numKeys, numValues;
    FREGetArrayLength(keys, &numKeys);
    FREGetArrayLength(vals, &numValues);
    
    uint32_t stringLength;
    uint32_t numItems = MIN(numKeys, numValues);
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithCapacity:numItems];
    for (uint32_t i = 0; i < numItems; i++)
    {
        FREObject keyRaw, valueRaw;
        FREGetArrayElementAt(keys, i, &keyRaw);
        FREGetArrayElementAt(vals, i, &valueRaw);
        
        // Convert key and value to strings. Skip with warning if not possible.
        const uint8_t *keyString;
        double valueDbl;
        if (FREGetObjectAsUTF8(keyRaw, &stringLength, &keyString) != FRE_OK || FREGetObjectAsDouble(valueRaw, &valueDbl) != FRE_OK)
        {
            NSLog(@"Couldn't convert FREObject to NSString at index %u", i);
            continue;
        }
        
        NSString *key = [NSString stringWithUTF8String:(char*)keyString];
        NSNumber *val = [NSNumber numberWithDouble:valueDbl];
        [mutableDictionary setObject:val forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:mutableDictionary];
}


-(void)callCoreImageFilterWithArgv:(FREObject*)argv argc:(uint32_t)argc
{
    
    FREBitmapData  bitmapData;
    
    FREAcquireBitmapData(argv[0], &bitmapData);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef inputContextRef     = CGBitmapContextCreate (
                                                              bitmapData.bits32,
                                                              bitmapData.width,
                                                              bitmapData.height,
                                                              8,
                                                              bitmapData.lineStride32 * 4,
                                                              colorSpace,
                                                              kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little
                                                              );
    
    CGImageRef inputImageRef        = CGBitmapContextCreateImage(inputContextRef);
    CIImage *inputImage             = [CIImage imageWithCGImage: inputImageRef];
    
    uint32_t stringLength;
    const uint8_t *nameString;
    FREObject nameFre =argv[1];
    FREGetObjectAsUTF8(nameFre, &stringLength, &nameString);
    NSString *name = [NSString stringWithUTF8String:(char*)nameString];
    
    CIFilter *filter = [CIFilter filterWithName:name];
    [filter setValue:inputImage forKey:@"inputImage"];
    
    
    if(argc > 2)
    {
        FREObject keys =argv[2];
        FREObject vals =argv[3];
        NSDictionary *dict = [iosfilters freObjeToDictWithKeys:keys values:vals];
        [filter setValuesForKeysWithDictionary:dict];
        /*
        for(id key in dict)
        {
            [filter setValue:[dict objectForKey:key] forKey:key];
        }
         */
        
       
    }
   
    CGImageRef outRef = [_cicontext createCGImage:[filter outputImage] fromRect:filter.outputImage.extent];
    
    CGContextRelease(inputContextRef);
    CGImageRelease(inputImageRef);
    
    
    
    NSUInteger width = CGImageGetWidth(outRef);
    NSUInteger height = CGImageGetHeight(outRef);
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context2 = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context2, CGRectMake(0, 0, width, height), outRef);
    CGContextRelease(context2);
    
    // Pixels are now it rawData in the format RGBA8888
    // Now loop over each pixel to write them into the AS3 BitmapData memory
    int x, y;
    // There may be extra pixels in each row due to the value of lineStride32.
    // We'll skip over those as needed.
    int offset = bitmapData.lineStride32 - bitmapData.width;
    int offset2 = (int)(bytesPerRow - bitmapData.width*4);
    int byteIndex = 0;
    uint32_t *bitmapDataPixels = bitmapData.bits32;
    for (y=0; y<bitmapData.height; y++)
    {
        for (x=0; x<bitmapData.width; x++, bitmapDataPixels++, byteIndex += 4)
        {
            // Values are currently in RGBA7777, so each color value is currently a separate number.
            int red     = (rawData[byteIndex]);
            int green   = (rawData[byteIndex + 1]);
            int blue    = (rawData[byteIndex + 2]);
            int alpha   = (rawData[byteIndex + 3]);
            
            // Combine values into ARGB32
            *bitmapDataPixels = (alpha << 24) | (red << 16) | (green << 8) | blue;
        }
        
        bitmapDataPixels += offset;
        byteIndex += offset2;
    }
    
    // Free the memory we allocated
    free(rawData);
    
    // Tell Flash which region of the BitmapData changes (all of it here)
    FREInvalidateBitmapDataRect(argv[0], 0, 0, bitmapData.width, bitmapData.height);
    
    // Release our control over the BitmapData
    FREReleaseBitmapData(argv[0]);
    
    CGImageRelease(outRef);
}



@end




DEFINE_ANE_FUNCTION(CreateSigContext)
{
    
    [[iosfilters sharedInstance] createSigContext];
    return nil;
}

DEFINE_ANE_FUNCTION(CoreImageFilterRequest)
{
    
    [[iosfilters sharedInstance] callCoreImageFilterWithArgv:argv argc:argc];
    return nil;
}


void FiltersContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                               uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    
    NSInteger nbFuntionsToLink = 2;
    *numFunctionsToTest = (uint32_t) nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "CreateSigContext";
    func[0].functionData = NULL;
    func[0].function = &CreateSigContext;
    
    func[1].name = (const uint8_t*) "CoreImageFilterRequest";
    func[1].functionData = NULL;
    func[1].function = &CoreImageFilterRequest;
    *functionsToSet = func;
    
    IOSFiltersCtx = ctx;
    
}

void FiltersContextFinalizer(FREContext ctx)
{
    IOSFiltersCtx = nil;
    return;
}

void FiltersExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                           FREContextFinalizer* ctxFinalizerToSet)
{
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &FiltersContextInitializer;
    *ctxFinalizerToSet = &FiltersContextFinalizer;
}

void FiltersExtFinalizer(void* extData)
{
    return;
}