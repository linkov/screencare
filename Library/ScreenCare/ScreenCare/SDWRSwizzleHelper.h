//
//  SDWRSwizzleHelper.h
//  ScreenCare
//
//  Created by alex on 7/11/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDWRSwizzleHelper : NSObject

+ (void)swizzClass:(Class)c selector:(SEL)orig selector:(SEL)replace;

@end
