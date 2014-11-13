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

-(id)initWithUploadCareKey:(NSString *)uck slackHookUrl:(NSString *)slackUrl;
-(id)initWithUploadCareKey:(NSString *)uck slackHookUrl:(NSString *)slackUrl userID:(NSString *)uID;
-(id)initWithScreencareKey:(NSString *)token;

@end
