//
//  SDWTextView.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//
#import "SDWCircle.h"
#import "SDWMarkerView.h"

@implementation SDWMarkerView {

    SDWCircle *touchCircle;
    SDWCircle *activeCircle;
    NSMutableDictionary *circles;
    BOOL isMovingExisitingCircle;
}

- (id)initWithFrame:(CGRect)frame delegate:(id<SDWViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self setupView];
    }
    return self;
}

- (void) setupView {

    circles = [NSMutableDictionary dictionary];

    touchCircle = [[SDWCircle alloc]initWithRadius:20];

    [self.layer addSublayer:touchCircle];

    touchCircle.hidden = YES;
}

- (SDWCircle *)circleAtPoint:(CGPoint)point {

    SDWCircle *circle = circles[[NSValue valueWithCGRect:CGRectMake(point.x, point.y, 40, 40)]];
    return circle;
}

-(void)removeCircleAtPoint:(CGPoint)point {

    SDWCircle *circle = circles[[NSValue valueWithCGRect:CGRectMake(point.x, point.y, 40, 40)]];
    [circle removeFromSuperlayer];
    
    [circles removeObjectForKey:[NSValue valueWithCGRect:CGRectMake(point.x, point.y, 40, 40)]];

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGRect pointerRect = CGRectMake(touchPoint.x, touchPoint.y, 40, 40);



    if (circles.count>0) {

        for (NSValue *rectValue in circles.keyEnumerator) {

            SDWCircle * intersectCircle = circles[ rectValue ];
            CGRect intersectRect = CGRectMake(intersectCircle.position.x, intersectCircle.position.y, 40, 40);

            if ( CGRectIntersectsRect(pointerRect, intersectRect) ) {

                activeCircle = intersectCircle;
                intersectCircle.position = touchPoint;
                isMovingExisitingCircle = YES;

            }


        }




        if (isMovingExisitingCircle) {

            CGRect activeCircleRect = CGRectMake(activeCircle.position.x, activeCircle.position.y, 40, 40);
            [circles removeObjectForKey:[NSValue valueWithCGRect:activeCircleRect]];
        }
        else {
            
            touchCircle.position = touchPoint;
            touchCircle.hidden = NO;
        }

    }
    else {

        touchCircle.position = touchPoint;
        touchCircle.hidden = NO;
        isMovingExisitingCircle = NO;
    }




}

- (BOOL)isCircleInDeleteAreaAtPoint:(CGPoint)point {

     CGRect deleteArea = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-80, 320, 80);

    if (CGRectContainsPoint(deleteArea, point)) return YES;

    return NO;


}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {



    if (isMovingExisitingCircle) {

        activeCircle.position = [[touches anyObject] locationInView:self];


        if ([self isCircleInDeleteAreaAtPoint:activeCircle.position]) {

            activeCircle.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor;
        }
        else {

            activeCircle.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2].CGColor;
        }



    }
    else {

        touchCircle.position = [[touches anyObject] locationInView:self];

        if ([self isCircleInDeleteAreaAtPoint:touchCircle.position]) {

            touchCircle.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor;
        }
        else {

            touchCircle.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2].CGColor;
        }

    }


}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {


    if (isMovingExisitingCircle) {

        activeCircle.position = [[touches anyObject] locationInView:self];

        if (![self isCircleInDeleteAreaAtPoint:activeCircle.position]) {

            CGRect intersectRect = CGRectMake(activeCircle.position.x, activeCircle.position.y, 40, 40);
            circles[[NSValue valueWithCGRect:intersectRect]] = activeCircle;
            [self animateTextNoteFromCircle:activeCircle];

        }
        else {

            [activeCircle removeFromSuperlayer];
        }

        isMovingExisitingCircle = NO;


    }
    else {

        touchCircle.position = [[touches anyObject] locationInView:self];
        touchCircle.hidden = YES;
        if (![self isCircleInDeleteAreaAtPoint:touchCircle.position]) {
           [self vendCircleAtPoint:touchCircle.position];
            [self animateTextNoteFromCircle:touchCircle];
        }

    }


}

- (void)animateTextNoteFromCircle:(SDWCircle*)circle {

    [self.delegate view:self didProvideMarkerPoint:circle.position];

}

-(void)vendCircleAtPoint:(CGPoint)point {

    SDWCircle *circle =  [[SDWCircle alloc]initWithRadius:20];
    circle.position = point;
    [self.layer addSublayer:circle];

    CGRect intersectRect = CGRectMake(point.x, point.y, 40, 40);

    circles[[NSValue valueWithCGRect:intersectRect]] = circle;
}

@end
