//
//  SDWDrawingView.m
//  Screenr
//
//  Created by alex on 6/28/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWDrawingView.h"


@implementation SDWDrawingView {

    CGPoint previousPoint;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
        self.backgroundColor = [UIColor clearColor];
		self.mainPath = [[UIBezierPath alloc]init];
		self.mainPath.lineCapStyle = kCGLineCapRound;
		self.mainPath.miterLimit = 0;
		self.mainPath.lineWidth = 2;

		UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearPath)];
		deleteTap.numberOfTouchesRequired = 2;
		deleteTap.numberOfTapsRequired = 1;
		[self addGestureRecognizer:deleteTap];

		// Capture touches
		UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
		pan.maximumNumberOfTouches = pan.minimumNumberOfTouches = 1;
		[self addGestureRecognizer:pan];
	}
	return self;
}

-(void)clearPath {

    [self.mainPath removeAllPoints];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    [self.brush setStroke];
    [self.mainPath strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint midPoint = midpoint(previousPoint, currentPoint);

    if (pan.state == UIGestureRecognizerStateBegan) {
        [self.mainPath moveToPoint:currentPoint];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self.mainPath addQuadCurveToPoint:midPoint controlPoint:previousPoint];
    }

    previousPoint = currentPoint;

    [self setNeedsDisplay];
}


static CGPoint midpoint(CGPoint p0, CGPoint p1) {
    return (CGPoint) {
        (p0.x + p1.x) / 2.0,
        (p0.y + p1.y) / 2.0
    };
}


@end
