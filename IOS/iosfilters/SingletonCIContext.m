//
//  SingletonCIContext.m
//  iosfilters
//
//  Created by Azer Bulbul on 10/14/14.
//  Copyright (c) 2014 azer. All rights reserved.
//

#import "SingletonCIContext.h"

@interface SingletonCIContext ()
@property CIContext *context;
@end

@implementation SingletonCIContext

static SingletonCIContext *contextObject = nil;

+(CIContext*)context
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        contextObject = [[self alloc] init];
    });
    
    return contextObject.context;
}

-(id)init {
    if(self = [super init])
    {
        EAGLContext *myEAGLContext = [[EAGLContext alloc]
                                      initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSDictionary *options = @{ kCIContextWorkingColorSpace : [NSNull null] };
        
        self.context = [CIContext contextWithEAGLContext:myEAGLContext
                                                 options:options];
    }
    
    return self;
}

@end

/*
 CIContext *context = [CIContext contextWithOptions:nil];
*/