//
//  SVProgressHUD.m
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>


@interface SVProgressHUD (private)

- (void)showInView:(UIView *)view status:(NSString *)string networkIndicator:(BOOL)show posY:(CGFloat)posY;
- (void)setStatus:(NSString *)string;
- (void)dismiss;
- (void)dismissWithStatus:(NSString *)string error:(BOOL)error;

@end


@implementation SVProgressHUD

static SVProgressHUD *sharedView = nil;

+ (SVProgressHUD*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[SVProgressHUD alloc] initWithFrame:CGRectZero];
	
	return sharedView;
}

+ (void)setStatus:(NSString *)string {
	[[SVProgressHUD sharedView] setStatus:string];
}

#pragma mark -
#pragma mark Show Methods


+ (void)show {
	[SVProgressHUD showInView:[UIApplication sharedApplication].keyWindow status:nil];
}


+ (void)showInView:(UIView*)view {
	[SVProgressHUD showInView:view status:nil];
}


+ (void)showInView:(UIView*)view status:(NSString*)string {
	[SVProgressHUD showInView:view status:string networkIndicator:YES];
}


+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show {
	[SVProgressHUD showInView:view status:string networkIndicator:show posY:floor(CGRectGetHeight(view.bounds)/2)-100];
}


+ (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY {
	[[SVProgressHUD sharedView] showInView:view status:string networkIndicator:show posY:posY];
}


#pragma mark -
#pragma mark Dismiss Methods

+ (void)dismiss {
	[[SVProgressHUD sharedView] dismiss];
}


+ (void)dismissWithSuccess:(NSString*)successString {
	[[SVProgressHUD sharedView] dismissWithStatus:successString error:NO];
}


+ (void)dismissWithError:(NSString*)errorString {
	[[SVProgressHUD sharedView] dismissWithStatus:errorString error:YES];
}

#pragma mark -
#pragma mark Instance Methods

- (void)dealloc {
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])) {
		self.layer.cornerRadius = 10;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
		self.userInteractionEnabled = NO;
		self.alpha = 0;

		stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor whiteColor];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		stringLabel.textAlignment = UITextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:16];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
		[self addSubview:stringLabel];
		[stringLabel release];
		
		imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		[self addSubview:imageView];
		[imageView release];
		
		spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinnerView.contentMode = UIViewContentModeTopLeft;
		spinnerView.hidesWhenStopped = YES;
		spinnerView.bounds = CGRectMake(0, 0, 36, 36);
		[self addSubview:spinnerView];
		[spinnerView release];
    }
	
    return self;
}

- (void)setStatus:(NSString *)string {
	
	CGFloat stringWidth = [string sizeWithFont:stringLabel.font].width+28;
	
	if(stringWidth < 100)
		stringWidth = 100;
	
	self.bounds = CGRectMake(0, 0, ceil(stringWidth/2)*2, 100);
	
	imageView.center = CGPointMake(CGRectGetWidth(self.bounds)/2, 36);
	
	stringLabel.hidden = NO;
	stringLabel.text = string;
	stringLabel.frame = CGRectMake(0, 66, CGRectGetWidth(self.bounds), 20);
	
	if(string)
		spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2), 40);
	else
		spinnerView.center = CGPointMake(ceil(CGRectGetWidth(self.bounds)/2), ceil(self.bounds.size.height/2));
}


- (void)showInView:(UIView*)view status:(NSString*)string networkIndicator:(BOOL)show posY:(CGFloat)posY {
	
	if(show)
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	else
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	imageView.hidden = YES;
	
	[self setStatus:string];
	
	if(![sharedView isDescendantOfView:view]) {
		[view addSubview:sharedView];
	
		posY+=(CGRectGetHeight(self.bounds)/2);
		self.center = CGPointMake(CGRectGetWidth(self.superview.bounds)/2, posY);
		
		[spinnerView startAnimating];
		
		self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1.3, 1.3, 1);
		self.layer.opacity = 0.3;
		
		[UIView animateWithDuration:0.15 animations:^{
			self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 1, 1, 1);
			self.layer.opacity = 1;
		}];
	}
}


- (void)dismiss {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	[UIView animateWithDuration:0.15
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{	
						 self.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, 0, 0), 0.8, 0.8, 1.0);
						 self.layer.opacity = 0;
					 }
					 completion:^(BOOL finished){ [sharedView removeFromSuperview]; }];
}


- (void)dismissWithStatus:(NSString*)string error:(BOOL)error {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if(error)
		imageView.image = [UIImage imageNamed:@"error.png"];
	else
		imageView.image = [UIImage imageNamed:@"success.png"];
	
	imageView.hidden = NO;
	
	[self setStatus:string];
	
	[spinnerView stopAnimating];
	
	if(fadeOutTimer != nil)
		[fadeOutTimer invalidate], [fadeOutTimer release], fadeOutTimer = nil;
	
	fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:0.9 target:self selector:@selector(dismiss) userInfo:nil repeats:NO] retain];
}



@end
