//
//  SDWScreenShotService.h
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDWScreenShotService : UIViewController

+(instancetype)sharedInstance;
-(id)initWithUploadCareKey:(NSString *)uck slaskHookUrl:(NSString *)slaskUrl;

@end
