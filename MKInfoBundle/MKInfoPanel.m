//
//  MKInfoPanel.m
//  HorizontalMenu
//
//  Created by Mugunth on 25/04/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/8e on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKInfoPanel.h"
#import <QuartzCore/QuartzCore.h>

// Private Methods

@interface MKInfoPanel ()

@property (nonatomic, assign) MKInfoPanelType type;

+ (MKInfoPanel*) infoPanel;

- (void)setup;
- (UIColor *)changeColor:(UIColor *)sourceColor withFactor:(CGFloat)factor;

@end


@implementation MKInfoPanel

@synthesize titleLabel = _titleLabel;
@synthesize detailLabel = _detailLabel;
@synthesize thumbImage = _thumbImage;
@synthesize backgroundGradient = _backgroundGradient;
@synthesize onTouched = _onTouched;
@synthesize delegate = _delegate;
@synthesize onFinished = _onFinished;
@synthesize type = type_;


////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [_delegate performSelector:_onFinished];
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter
////////////////////////////////////////////////////////////////////////

-(void)setType:(MKInfoPanelType)type {
    UIColor *startColor, *endColor;
    if(type == MKInfoPanelTypeError) {
        startColor = RGBA(200, 36, 0, 1.0);
        endColor = RGBA(150, 24, 0, 1.0);
        [self setBackgroundGradientFrom:startColor to:endColor];
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.detailLabel.font = [UIFont fontWithName:@"Helvetica Neue" 
                                                size:14];
        self.thumbImage.image = [UIImage imageNamed:@"Warning"];
        self.detailLabel.textColor = RGBA(255, 166, 166, 1.0);
    }
    
    else if(type == MKInfoPanelTypeInfo) {
        startColor = RGBA(91, 134, 206, 1.0);
        endColor = RGBA(69, 106, 177, 1.0);
        [self setBackgroundGradientFrom:startColor to:endColor];
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.thumbImage.image = [UIImage imageNamed:@"Tick"];   
        self.detailLabel.textColor = RGBA(210, 210, 235, 1.0);
    }
    
    else if(type == MKInfoPanelTypeNotice) {
        startColor = RGBA(253, 178, 77, 1.0);
        endColor = RGBA(196, 123, 20, 1.0);
        [self setBackgroundGradientFrom:startColor to:endColor];
        
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.thumbImage.image = [UIImage imageNamed:@"Tick"];   
        self.detailLabel.textColor = RGBA(136, 85, 24, 1.0);
    }
}

-(void)setBackgroundGradientFrom:(UIColor *)fromColor to:(UIColor *)toColor {
//    UIView *view = [[UIView alloc] initWithFrame:self.background.frame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.backgroundGradient.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[fromColor CGColor], (id)[toColor CGColor], nil];
    
    CGFloat lineHeight = 3.0;
    // light startline
    CAGradientLayer *startLine = [CAGradientLayer layer];
    startLine.frame = CGRectMake(0, 0, self.backgroundGradient.bounds.size.width, lineHeight);
    UIColor *lightColor = [self changeColor:fromColor withFactor:1.1];
    startLine.colors = [NSArray arrayWithObjects:(id)[fromColor CGColor], (id)[lightColor CGColor], nil];
    
    // dark endline
    CAGradientLayer *endLine = [CAGradientLayer layer];
    CGFloat endPosition = self.backgroundGradient.bounds.size.height - lineHeight;
    endLine.frame = CGRectMake(0, endPosition, self.backgroundGradient.bounds.size.width, lineHeight);
    UIColor *darkColor = [self changeColor:toColor withFactor:0.7];
    endLine.colors = [NSArray arrayWithObjects:(id)[toColor CGColor], (id)[darkColor CGColor], nil];
    
    [self.backgroundGradient.layer insertSublayer:gradient atIndex:0];
    [self.backgroundGradient.layer insertSublayer:startLine atIndex:1];
    [self.backgroundGradient.layer insertSublayer:endLine atIndex:2];
}

// @see http://www.cocoanetics.com/2009/10/manipulating-uicolors/
- (UIColor *)changeColor:(UIColor *)sourceColor withFactor:(CGFloat)factor
{
    // oldComponents is the array INSIDE the original color
    // changing these changes the original, so we copy it
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([sourceColor CGColor]);
    CGFloat newComponents[4];
    
    int numComponents = CGColorGetNumberOfComponents([sourceColor CGColor]);
    
    switch (numComponents)
    {
        case 2:
        {
            //grayscale
            newComponents[0] = oldComponents[0]*factor;
            newComponents[1] = oldComponents[0]*factor;
            newComponents[2] = oldComponents[0]*factor;
            newComponents[3] = oldComponents[1];
            break;
        }
        case 4:
        {
            //RGBA
            newComponents[0] = oldComponents[0]*factor;
            newComponents[1] = oldComponents[1]*factor;
            newComponents[2] = oldComponents[2]*factor;
            newComponents[3] = oldComponents[3];
            break;
        }
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *retColor = [UIColor colorWithCGColor:newColor];
    CGColorRelease(newColor);
    
    return retColor;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Show/Hide
////////////////////////////////////////////////////////////////////////

+ (MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInView:view type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInView:(UIView *)view type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {    
    MKInfoPanel *panel = [MKInfoPanel infoPanel];
    CGFloat panelHeight = 50;   // panel height when no subtitle set
	CGFloat panelWidht = panel.frame.size.width;
    
    panel.titleLabel.text = title;
    
    if(subtitle) {
        panel.detailLabel.text = subtitle;
        [panel.detailLabel sizeToFit];
        
        panelHeight = MAX(CGRectGetMaxY(panel.thumbImage.frame), CGRectGetMaxY(panel.detailLabel.frame));
        panelHeight += 10.f;    // padding at bottom
    } else {
        panel.detailLabel.hidden = YES;
        panel.thumbImage.frame = CGRectMake(15, 5, 35, 35);
        panel.titleLabel.frame = CGRectMake(57, 12, 240, 21);
    }
    
    // update frame of panel
	// TODO: parameterize if the panel should be in full width or just centered in the middle
	if (YES) { // sorry for this bad hack, I need to center the planel for a project
		CGFloat x = view.frame.size.width / 2 - panelWidht / 2;
		panel.frame = CGRectMake(x, 0, panelWidht, panelHeight);
	} else {
		panel.frame = CGRectMake(0, 0, view.bounds.size.width, panelHeight);
	}
	
    panel.type = type;
	[view performSelectorOnMainThread:@selector(addSubview:) withObject:panel waitUntilDone:YES];
    
    if (interval > 0) {
        [panel performSelector:@selector(hidePanel) withObject:view afterDelay:interval]; 
    }
    
    return panel;
}

+ (MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle {
    return [self showPanelInWindow:window type:type title:title subtitle:subtitle hideAfter:-1];
}

+(MKInfoPanel *)showPanelInWindow:(UIWindow *)window type:(MKInfoPanelType)type title:(NSString *)title subtitle:(NSString *)subtitle hideAfter:(NSTimeInterval)interval {
    MKInfoPanel *panel = [self showPanelInView:window type:type title:title subtitle:subtitle hideAfter:interval];
    
    if (![UIApplication sharedApplication].statusBarHidden) {
        CGRect frame = panel.frame;
        frame.origin.y += [UIApplication sharedApplication].statusBarFrame.size.height;
        panel.frame = frame;
    }
    
    return panel;
}

-(void)hidePanel {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromTop;
	[self.layer addAnimation:transition forKey:nil];
    self.frame = CGRectMake(self.frame.origin.x, -self.frame.size.height, self.frame.size.width, self.frame.size.height); 
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.25];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Touch Recognition
////////////////////////////////////////////////////////////////////////

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self performSelector:_onTouched];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private
////////////////////////////////////////////////////////////////////////

+(MKInfoPanel *)infoPanel {
    MKInfoPanel *panel =  (MKInfoPanel*) [[[UINib nibWithNibName:@"MKInfoPanel" bundle:nil] 
                                           instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionPush;	
	transition.subtype = kCATransitionFromBottom;
	[panel.layer addAnimation:transition forKey:nil];
    
    return panel;
}

- (void)setup {
    self.onTouched = @selector(hidePanel);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

@end
