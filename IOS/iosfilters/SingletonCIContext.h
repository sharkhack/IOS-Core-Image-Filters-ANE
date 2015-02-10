//
//  SingletonCIContext.h
//  iosfilters
//
//  Created by Azer Bulbul on 10/14/14.
//  Copyright (c) 2014 azer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface SingletonCIContext : NSObject
+(CIContext*)context;
@end
