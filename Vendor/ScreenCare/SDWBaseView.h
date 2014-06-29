//
//  SDWBaseView.h
//  Screenr
//
//  Created by alex on 6/29/14.
//  Copyright (c) 2014 SDWR. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDWViewDelegate;

@interface SDWBaseView : UIView

@property (nonatomic, weak) id <SDWViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<SDWViewDelegate>)delegate;

@end


@protocol SDWViewDelegate

@optional
- (void)view:(SDWBaseView *)view didProvideMarkerPoint:(CGPoint)point;
- (void)view:(SDWBaseView *)view didProvideTextForNote:(NSString *)text;
- (void)viewDidCancelText:(SDWBaseView *)view;


@end
