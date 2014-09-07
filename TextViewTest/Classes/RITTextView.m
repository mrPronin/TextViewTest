//
//  RITTextView.m
//  TextViewTest
//
//  Created by Aleksandr Pronin on 06.09.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITTextView.h"
#import "RITTextViewLayer.h"

@implementation RITTextView

#pragma mark -
#pragma mark UIView

+ (Class)layerClass
{
    return [RITTextViewLayer class];
}

#pragma mark -
#pragma mark Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self finishInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self finishInit];
}

- (void)finishInit
{
    self.layer.geometryFlipped = YES;
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
}

#pragma mark -
#pragma mark Accessors

- (NSAttributedString *)attributedString
{
    return [self.textLayer attributedString];
}

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    [self.textLayer setAttributedString:attributedString];
}

- (RITTextViewLayer *)textLayer
{
    return (RITTextViewLayer*)self.layer;
}

- (CGFloat)textInset
{
    return [self.textLayer textInset];
}

- (void)setTextInset:(CGFloat)textInset
{
    [self.textLayer setTextInset:textInset];
}

@end
