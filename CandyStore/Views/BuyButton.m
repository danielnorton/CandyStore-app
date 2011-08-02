//
//  BuyButton.m
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BuyButton.h"
#import "Style.h"


@interface BuyButton()

- (void)initializeBuyButton;

@end

@implementation BuyButton


#pragma mark -
#pragma mark UIView
- (id)initWithFrame:(CGRect)aFrame {
	if (![super initWithFrame:aFrame]) return nil;
	
	[self initializeBuyButton];
	
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	
	[self initializeBuyButton];
}


#pragma mark NSCoder
- (id)initWithCoder:(NSCoder *)decoder {
	if (![super initWithCoder:decoder]) return nil;
	
	[self initializeBuyButton];
	
	return self;
}


#pragma mark UITableViewCell
- (void)setSelected:(BOOL)isSelected {

	UIControlState currentState = isSelected
	? UIControlStateNormal
	: UIControlStateSelected;
	
	UIControlState nextState = isSelected
	? UIControlStateSelected
	: UIControlStateNormal;
	
	
	NSString *nextText = [self titleForState:nextState];
	NSString *currentText = [self titleForState:currentState];
	
	CGSize newSize = [nextText sizeWithFont:self.titleLabel.font];
	CGSize currentSize = [currentText sizeWithFont:self.titleLabel.font];
	float widthDiffernce = newSize.width - currentSize.width;
	
	float newW = self.frame.size.width + widthDiffernce;
	float newX = self.frame.origin.x - widthDiffernce;
	CGRect newFrame = CGRectMake(newX, self.frame.origin.y, newW, self.frame.size.height);
	
	[self.titleLabel setAlpha:0.0f];
	
	// bug when using stretched background images with a UIButton
	// http://openradar.appspot.com/7290242
	// but this is pretty close to the App Store 'buy button'
	[UIView animateWithDuration:0.165f
					 animations:^{
						 
						 [super setSelected:isSelected];
						 [self setFrame:newFrame];
					 }
					 completion:^(BOOL finished) {
						 
						 [self.titleLabel setAlpha:1.0f];
					 }];
}


#pragma mark BuyButton
- (void)initializeBuyButton {
	
	UIImage *blue = [[UIImage imageNamed:@"blueBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f];
	UIImage *green = [[UIImage imageNamed:@"greenBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0.0f];
	
	[self setBackgroundColor:[UIColor clearColor]];
	[self setBackgroundImage:blue forState:UIControlStateNormal];
	[self setBackgroundImage:green forState:UIControlStateSelected];
	
	[self.titleLabel setTextColor:[UIColor buyButtonTextColor]];
	[self.titleLabel setShadowColor:[UIColor buyButtonShadowColor]];
	[self.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
}

@end
