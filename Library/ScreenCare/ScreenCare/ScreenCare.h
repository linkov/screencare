//
//  ScreenCare.h
//  ScreenCare
//
//  Created by alex on 6/29/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ScreenCare : UIViewController

+(instancetype)sharedInstance;
-(id)initWithUploadCareKey:(NSString *)uck slackHookUrl:(NSString *)slackUrl;

@end
