//
//  SDWCircle.m
//  Screenr
//
//  Created by alex on 6/29/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import "SDWCircle.h"

@implementation SDWCircle {

    UILabel *numberLabel;
}

- (id)initWithRadius:(CGFloat)radius {

    self = [super init];
    if (self) {

        self.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0 * radius, 2.0 * radius) cornerRadius:radius].CGPath;
        self.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2].CGColor;
        numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        numberLabel.font = [UIFont systemFontOfSize:12];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.backgroundColor = [UIColor clearColor];
        [self addSublayer:numberLabel.layer];

    }
    return self;
}

- (void)setNumber:(NSUInteger)number {

    _number = number;
    numberLabel.text = [NSString stringWithFormat:@"%i",number];
    [self setNeedsLayout];
}

@end
