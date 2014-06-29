//
//  SDWTextView.h
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
@class SDWCircle;
#import "SDWBaseView.h"
#import <UIKit/UIKit.h>

@interface SDWMarkerView : SDWBaseView

-(SDWCircle *)circleAtPoint:(CGPoint)point;
-(void)removeCircleAtPoint:(CGPoint)point;

@end
