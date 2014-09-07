//
//  RITTextViewLayer.m
//  TextViewTest
//
//  Created by Aleksandr Pronin on 06.09.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITTextViewLayer.h"
#import <CoreText/CoreText.h>
#import <malloc/malloc.h>

// Other constants
static const CFRange kRangeZero = {0, 0};

@interface RITTextViewLayer ()

@property (nonatomic, readwrite, strong) __attribute__((NSObject)) CTTypesetterRef typesetter;

@end

@implementation RITTextViewLayer
{
    CGFloat *_adjustmentBuffer;
    CGPoint *_positionsBuffer;
    CGGlyph *_glyphsBuffer;
}

#pragma mark -
#pragma mark Main drawing

- (void)drawInContext:(CGContextRef)context
{
    if (self.attributedString == nil) {
        return;
    }
    
    // Initialize the context (always initialize your text matrix)
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    // Work out the geometry
    CGRect insetBounds = CGRectInset([self bounds], 5.0, 5.0);
    CGFloat boundsWidth = CGRectGetWidth(insetBounds);
    
    // Start in the upper-left corner
    CGPoint textOrigin = CGPointMake(CGRectGetMinX(insetBounds),
                                     CGRectGetMaxY(insetBounds));
    
    // For each line, until we run out of text or vertical space
    CFIndex startIndex = 0;
    NSUInteger stringLength = self.attributedString.length;
    while (startIndex < stringLength && textOrigin.y > insetBounds.origin.y) {
        CGFloat ascent, descent, leading;
        CTLineRef line = [self copyLineAtIndex:startIndex
                                      forWidth:boundsWidth
                                        ascent:&ascent
                                       descent:&descent
                                       leading:&leading];
        
        // Move forward to the baseline
        textOrigin.y -= ascent;
        CGContextSetTextPosition(context, textOrigin.x, textOrigin.y);
        
        // Draw each glyph run
        for (id runID in (__bridge id)CTLineGetGlyphRuns(line)) {
            [self drawRun:(__bridge CTRunRef)runID inContext:context textOrigin:textOrigin];
        }
        
        // Move the index beyond the line break.
        startIndex += CTLineGetStringRange(line).length;
        textOrigin.y -= descent + leading + 1; // +1 matches best to CTFramesetter's behavior
        CFRelease(line);
    }
}

#pragma mark -
#pragma mark Typesetting

- (CTLineRef)copyLineAtIndex:(CFIndex)startIndex
                    forWidth:(CGFloat)boundsWidth
                      ascent:(CGFloat *)ascent
                     descent:(CGFloat *)descent
                     leading:(CGFloat *)leading
{
    // Calculate the line
    CFIndex lineCharacterCount = CTTypesetterSuggestLineBreak(self.typesetter, startIndex, boundsWidth);
    CTLineRef line = CTTypesetterCreateLine(self.typesetter, CFRangeMake(startIndex, lineCharacterCount));
    
    // Fetch the typographic bounds
    CTLineGetTypographicBounds(line, &(*ascent), &(*descent), &(*leading));
    
    // Full-justify all lines
    CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0, boundsWidth);
    CFRelease(line);
    line = justifiedLine;
    return line;
}

#pragma mark -
#pragma mark Draw glyph runs

- (void)drawRun:(CTRunRef)run inContext:(CGContextRef)context textOrigin:(CGPoint)textOrigin
{
    [self applyStylesFromRun:run toContext:context];
    
    size_t glyphCount = (size_t)CTRunGetGlyphCount(run);
    
    CGPoint *positions = [self positionsForRun:run];
    
    const CGGlyph *glyphs = [self glyphsForRun:run];
    CGContextShowGlyphsAtPositions(context, glyphs, positions, glyphCount);
}

#pragma mark -
#pragma mark Styles

- (void)applyStylesFromRun:(CTRunRef)run toContext:(CGContextRef)context
{
    NSDictionary *attributes = (__bridge id)CTRunGetAttributes(run);
    
    // Set the font
    CTFontRef runFont = (__bridge CTFontRef)attributes[NSFontAttributeName];
    CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
    CGContextSetFont(context, cgFont);
    CGContextSetFontSize(context, CTFontGetSize(runFont));
    CFRelease(cgFont);
    
    // Set the color
    UIColor *color = attributes[NSForegroundColorAttributeName];
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    // Any other style setting would go here
}

#pragma mark -
#pragma mark Positioning

- (CGPoint *)positionsForRun:(CTRunRef)run
{
    // This is slightly dangerous. We're getting a pointer to the internal
    // data, and yes, we're modifying it. But it avoids copying the memory
    // in most cases, which can get expensive.
    // Setup our buffers
    CGPoint *positions = (CGPoint *)CTRunGetPositionsPtr(run);
    if (positions == NULL) {
        ResizeBufferToAtLeast((void **)&_positionsBuffer, sizeof(CGPoint) * CTRunGetGlyphCount(run));
        CTRunGetPositions(run, kRangeZero, _positionsBuffer);
        positions = _positionsBuffer;
    }
    return positions;
}

#pragma mark -
#pragma mark Glyphs

- (const CGGlyph *)glyphsForRun:(CTRunRef)run
{
    // This one is less dangerous since we don't modify it, and we keep the const
    // to remind ourselves that it's not to be modified lightly.
    const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
    if (glyphs == NULL) {
        ResizeBufferToAtLeast((void **)&_glyphsBuffer, sizeof(CGGlyph) * CTRunGetGlyphCount(run));
        CTRunGetGlyphs(run, kRangeZero, _glyphsBuffer);
        glyphs = _glyphsBuffer;
    }
    return glyphs;
}


#pragma mark -
#pragma mark Buffers

void ResizeBufferToAtLeast(void **buffer, size_t size) {
    if (!*buffer || malloc_size(*buffer) < size) {
        *buffer = realloc(*buffer, size);
    }
}

- (CGFloat *)adjustmentBufferForCount:(NSUInteger)count
{
    ResizeBufferToAtLeast((void **)&_adjustmentBuffer, sizeof(CGPoint) * count);
    return _adjustmentBuffer;
}

#pragma mark -
#pragma mark Accessors

- (void)setAttributedString:(NSAttributedString *)attributedString
{
    if (attributedString != _attributedString) {
        _attributedString = attributedString;
        self.typesetter = CTTypesetterCreateWithAttributedString((__bridge CFTypeRef)_attributedString);
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Init/Dealloc

- (id)init
{
    self = [super init];
    if (self) {
        //_touchPointForIdentifier = [NSMutableDictionary new];
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        _typesetter = [layer typesetter];
        _attributedString = [layer attributedString];
        //_touchPointForIdentifier = [layer touchPointForIdentifier];
    }
    return self;
}

/*
#pragma mark -
#pragma mark CALayer

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:kTouchPointForIdentifierName]) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:key];
    }
}
*/

@end
