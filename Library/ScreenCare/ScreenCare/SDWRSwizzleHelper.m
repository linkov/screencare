//
//  SDWRSwizzleHelper.m
//  ScreenCare
//
//  Created by alex on 7/11/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import <objc/runtime.h>
#import "SDWRSwizzleHelper.h"

@implementation SDWRSwizzleHelper

+ (void)swizzClass:(Class)c selector:(SEL)orig selector:(SEL)replace
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, replace);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, replace, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@end
