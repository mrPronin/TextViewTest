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
    CGFloat _paragraphSpacing;
    CGFloat _lineSpacing;
    CGFloat _lineSpacingStretchStep;
    CGFloat _paragraphSpacingShrinkStep;
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
    
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- frame: %@ bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(self.frame), NSStringFromCGRect(self.bounds));
    // RIT DEBUG
    
    // Work out the geometry
    CGRect insetBounds = CGRectInset([self bounds], _textInset, _textInset);
    CGFloat boundsWidth = CGRectGetWidth(insetBounds);
    
    // RIT DEBUG
    NSLog(@"[%@ %@] -- insetBounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(insetBounds));
    // RIT DEBUG
    
    // RIT DEBUG
    CGFloat textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:_lineSpacing andParagraphSpacing:_paragraphSpacing];
    NSLog(@"[%@ %@] -- textHeight: %f", [self class], NSStringFromSelector(_cmd), textHeight);
    // RIT DEBUG
    
    [self adjustSpacingWithInsetBounds:insetBounds lineSpacing:_lineSpacing andParapraphSpacing:_paragraphSpacing];
    
    // RIT DEBUG
    textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:_lineSpacing andParagraphSpacing:_paragraphSpacing];
    NSLog(@"[%@ %@] -- textHeight: %f", [self class], NSStringFromSelector(_cmd), textHeight);
    // RIT DEBUG
    
    // Start in the upper-left corner
    CGPoint textOrigin = CGPointMake(CGRectGetMinX(insetBounds),
                                     CGRectGetMaxY(insetBounds));
    
    // For each line, until we run out of text or vertical space
    CFIndex startIndex = 0;
    NSUInteger stringLength = self.attributedString.length;
    while (startIndex < stringLength && textOrigin.y > insetBounds.origin.y) {
        CGFloat ascent, descent, leading;
        // RIT DEBUG
        //NSLog(@"ascent: %f descent: %f leading: %f line height: %f", ascent, descent, leading, (ascent + descent + leading));
        // RIT DEBUG
        BOOL isParagraph = NO;
        CTLineRef line = [self copyLineAtIndex:startIndex
                                      forWidth:boundsWidth
                                        ascent:&ascent
                                       descent:&descent
                                       leading:&leading
                          isParagraph:&isParagraph];
        
        // Move forward to the baseline
        textOrigin.y -= ascent;
        CGContextSetTextPosition(context, textOrigin.x, textOrigin.y);
        // RIT DEBUG
        //NSLog(@"textOrigin: %@", NSStringFromCGPoint(textOrigin));
        // RIT DEBUG
        // Draw each glyph run
        for (id runID in (__bridge id)CTLineGetGlyphRuns(line)) {
            [self drawRun:(__bridge CTRunRef)runID inContext:context textOrigin:textOrigin];
        }
        
        // RIT DEBUG
        //NSLog(@"isParagraph: %d", isParagraph);
        // RIT DEBUG
        
        // Move the index beyond the line break.
        startIndex += CTLineGetStringRange(line).length;
        textOrigin.y -= descent + leading + _lineSpacing + (isParagraph? _paragraphSpacing : 0);
        CFRelease(line);
    }
}

#pragma mark -
#pragma mark Text height adjustment

- (CGFloat)textHeightWithInsetBounds:(CGRect)insetBounds
                         lineSpacing:(CGFloat)lineSpacing
                 andParagraphSpacing:(CGFloat)paragraphSpacing
{
    CGFloat textHeight = 0;
    CGFloat boundsWidth = CGRectGetWidth(insetBounds);
    CFIndex startIndex = 0;
    NSUInteger stringLength = self.attributedString.length;
    while (startIndex < stringLength)
    {
        CGFloat ascent, descent, leading;
        BOOL isParagraph = NO;
        CTLineRef line = [self copyLineAtIndex:startIndex
                                      forWidth:boundsWidth
                                        ascent:&ascent
                                       descent:&descent
                                       leading:&leading
                                   isParagraph:&isParagraph];
        
        textHeight += ascent + descent + leading + lineSpacing + (isParagraph? paragraphSpacing : 0);
        startIndex += CTLineGetStringRange(line).length;
        CFRelease(line);
    }
    return textHeight;
}

- (void)adjustSpacingWithInsetBounds:(CGRect)insetBounds lineSpacing:(CGFloat)lineSpacing andParapraphSpacing:(CGFloat)paragraphSpacing
{
    CGFloat textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:lineSpacing andParagraphSpacing:paragraphSpacing];
    
    // first check if we fit with current spacing
    if (textHeight > CGRectGetHeight(insetBounds)) {
        // needs to shrink text height
        
        // try to shrink with line spacing
        CGFloat newLineSpacing = 0;
        if ([self shrinkToLineSpacing:&newLineSpacing
                      withInsetBounds:insetBounds
                          lineSpacing:lineSpacing
                  andParapraphSpacing:paragraphSpacing])
        {
            
            _lineSpacing = newLineSpacing;
            return;
        }
        
        // try to shrink with paragraph spacing
        CGFloat newParagraphSpacing = 0;
        if ([self shrinkToParagraphSpacing:&newParagraphSpacing
                           withInsetBounds:insetBounds
                               lineSpacing:lineSpacing
                       andParapraphSpacing:paragraphSpacing])
        {
            _paragraphSpacing = newParagraphSpacing;
            return;
        }
        
        NSLog(@"Unable to shrink text to inset bounds!");
        
    } else {
        // needs to stretch text height
        CGFloat newLineSpacing = 0;
        [self stretchToLineSpacing:&newLineSpacing
                   withInsetBounds:insetBounds
                       lineSpacing:lineSpacing
               andParapraphSpacing:paragraphSpacing];
        _lineSpacing = newLineSpacing;
    }
}

- (void)stretchToLineSpacing:(CGFloat *)newLineSpacing
             withInsetBounds:(CGRect)insetBounds
                 lineSpacing:(CGFloat)lineSpacing
         andParapraphSpacing:(CGFloat)paragraphSpacing
{
    CGFloat appropriateLineSpacing, currentLineSpacing;
    appropriateLineSpacing = currentLineSpacing = lineSpacing;
    CGFloat textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:lineSpacing andParagraphSpacing:paragraphSpacing];
    while (textHeight < CGRectGetHeight(insetBounds))
    {
        appropriateLineSpacing = currentLineSpacing;
        currentLineSpacing += _lineSpacingStretchStep;
        textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:currentLineSpacing andParagraphSpacing:paragraphSpacing];
    }
    *newLineSpacing = appropriateLineSpacing;
}

- (BOOL)shrinkToParagraphSpacing:(CGFloat *)newParagraphSpacing
                 withInsetBounds:(CGRect)insetBounds
                     lineSpacing:(CGFloat)lineSpacing
             andParapraphSpacing:(CGFloat)paragraphSpacing
{
    if (paragraphSpacing == 0) {
        *newParagraphSpacing = 0;
        return NO;
    }
    CGFloat textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:lineSpacing andParagraphSpacing:paragraphSpacing];
    CGFloat currentParagraphSpacing = paragraphSpacing;
    while (textHeight > CGRectGetHeight(insetBounds) && currentParagraphSpacing > 0)
    {
        currentParagraphSpacing -= _paragraphSpacingShrinkStep;
        textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:lineSpacing andParagraphSpacing:currentParagraphSpacing];
    }
    
    if (textHeight > CGRectGetHeight(insetBounds)) {
        *newParagraphSpacing = 0;
        return NO;
    } else {
        *newParagraphSpacing = currentParagraphSpacing;
        return YES;
    }
}

- (BOOL)shrinkToLineSpacing:(CGFloat *)newLineSpacing
            withInsetBounds:(CGRect)insetBounds
                lineSpacing:(CGFloat)lineSpacing
        andParapraphSpacing:(CGFloat)paragraphSpacing
{
    if (lineSpacing == 0) {
        *newLineSpacing = 0;
        return NO;
    }
    CGFloat textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:lineSpacing andParagraphSpacing:paragraphSpacing];
    CGFloat currentLineSpacing = lineSpacing;
    while (textHeight > CGRectGetHeight(insetBounds) && currentLineSpacing > 0)
    {
        currentLineSpacing -= _lineSpacingStretchStep;
        textHeight = [self textHeightWithInsetBounds:insetBounds lineSpacing:currentLineSpacing andParagraphSpacing:paragraphSpacing];
    }
    
    if (textHeight > CGRectGetHeight(insetBounds)) {
        *newLineSpacing = 0;
        return NO;
    } else {
        *newLineSpacing = currentLineSpacing;
        return YES;
    }
}

#pragma mark -
#pragma mark Typesetting

- (CTLineRef)copyLineAtIndex:(CFIndex)startIndex
                    forWidth:(CGFloat)boundsWidth
                      ascent:(CGFloat *)ascent
                     descent:(CGFloat *)descent
                     leading:(CGFloat *)leading
                 isParagraph:(BOOL *)paragraphLine
{
    // Calculate the line
    CFIndex lineCharacterCount = CTTypesetterSuggestLineBreak(self.typesetter, startIndex, boundsWidth);
    CTLineRef line = CTTypesetterCreateLine(self.typesetter, CFRangeMake(startIndex, lineCharacterCount));
    
    // Fetch the typographic bounds
    CTLineGetTypographicBounds(line, &(*ascent), &(*descent), &(*leading));
    
    // Full-justify all but last line of paragraphs
    NSString *string = self.attributedString.string;
    //NSUInteger endingLocation = startIndex + lineCharacterCount;
    
    NSString *lineString = [string substringWithRange:(NSRange){startIndex, lineCharacterCount}];
    
    // RIT DEBUG
    //NSLog(@"Line string: %@", lineString);
    /*
    if ([lineString hasSuffix:@"\n"]) {
        NSLog(@"Last paragraph line");
    }
    */
    // RIT DEBUG
    
    if (![lineString hasSuffix:@"\n"]) {
        CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0, boundsWidth);
        CFRelease(line);
        line = justifiedLine;
    } else {
        *paragraphLine = YES;
    }
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
        NSMutableParagraphStyle *paragraphStyle = [attributedString attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
        _paragraphSpacing = paragraphStyle.paragraphSpacing;
        _lineSpacing = paragraphStyle.lineSpacing;
        [self setNeedsDisplay];
    }
}

- (void)setTextInset:(CGFloat)textInset
{
    if (_textInset == textInset) return;
    _textInset = textInset;
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark Init/Dealloc

- (id)init
{
    self = [super init];
    if (self) {
        _textInset = 5.f;
        _lineSpacingStretchStep = 1.f;
        _paragraphSpacingShrinkStep = 1.f;
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        _typesetter = [layer typesetter];
        _attributedString = [layer attributedString];
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
