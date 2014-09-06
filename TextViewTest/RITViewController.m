//
//  RITViewController.m
//  TextViewTest
//
//  Created by Pronin Alexander on 26.08.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITViewController.h"
#import <CoreText/CoreText.h>

const CGFloat lineSpacingStretchStep = 1.f;
const CGFloat lineSpacingInitialValue = 0;
const CGFloat paragraphSpacingInitialValue = 10.f;
const CGFloat paragraphSpacingShrinkStep = 1.f;
const CGFloat fontSizeInitialValue = 16.f;

@interface RITViewController ()

@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) CGRect pageRect;

@end

@implementation RITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pageRect = CGRectMake(0, 64, 320, 460);
    //_textView.frame = _pageRect;
    /*
     _text = @"собрался домой. Кряхтя, поднялся из-за неудобного казённого стола и направился к шкафу, заваленному книгами и справочниками. Он уже убирал очередной том с собранием различных патентов в дальний угол, как вдруг отвлёкся на скрипнувшую дверь. Это вошёл его коллега и брат по несчастью, Уильям. Книга выпала из рук, раскрывшись на странице с затейливым рисунком. Лайл поправил очки и наклонился за книгой. Полнота делала этот процесс непростым.\n- Вот, смотри, - Лайл Гудхью ткнул толстым пальцем в описание патента номер 2170531.";
     */
    _text = @"В 1943-м году американские войска, дислоцированные в тропиках, подвергались серьезным атакам насекомых. Это было просто стихийным бедствием. Ни спать, ни есть комары не давали. Солдаты ходили вялые, мрачные, стреляли в молоко. Командование рапортовало о ситуации в центр, где к этому отнеслись серьезно и нашли двух экспертов для решения необычной задачи. Эксперты уселись изучать старые патенты и изобретения.\nУстав от длительных изысканий, Лайл, служащий Министерства Сельского Хозяйства, уже";
    
    //_textView.layoutManager.showsInvisibleCharacters = YES;
    
    [self layoutText:_text withTextView:self.textView];
    
    // RIT DEBUG
    NSLog(@"Text view frame: %@", NSStringFromCGRect(_textView.frame));
    // RIT DEBUG
    
    //self.heightConstraint.constant = CGRectGetHeight(_pageRect);
    
    //[_textView.layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textView.textStorage length])];
    
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- hasNonContiguousLayout: %d", [self class], NSStringFromSelector(_cmd), _textView.layoutManager.hasNonContiguousLayout);
    // RIT DEBUG
    
    /*
    NSRange lastCharRange = NSMakeRange([_text length] - 1, 1);
    NSString *lastChar = [_text substringWithRange:lastCharRange];
    */
    //[_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];
}

- (CGRect)lastCharRectForTextView:(UITextView *)textView andRange:(NSRange)textRange
{
    [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
    //[textView.layoutManager ensureLayoutForCharacterRange:textRange];
    UITextPosition *Pos1 = [textView positionFromPosition: textView.endOfDocument offset: -1];
    UITextPosition *Pos2 = [textView positionFromPosition: textView.endOfDocument offset: 0];
    
    UITextRange *range = [textView textRangeFromPosition:Pos1 toPosition:Pos2];
    
    return CGRectIntegral([textView firstRectForRange:(UITextRange *)range]);
}

- (NSAttributedString *)lastParagraphStretchingForAttributedText:(NSAttributedString *)attributedText andViewSize:(CGSize)size
{
    NSTextStorage *textStorege = [[NSTextStorage alloc] initWithAttributedString:attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorege addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    [layoutManager addTextContainer:textContainer];
    CGRect viewRect = CGRectMake(0, 0, size.width, size.height);
    UITextView *textView = [[UITextView alloc] initWithFrame:viewRect textContainer:textContainer];
    
    CGRect lastCharRect = [self lastCharRectForTextView:textView andRange:NSMakeRange(0, [textView.textStorage length])];
    
    CGFloat charMaxX = CGRectGetMaxX(lastCharRect);
    CGFloat viewMaxX = CGRectGetMaxX(textView.frame);
    
    NSLog(@"lastCharRect: %@", NSStringFromCGRect(lastCharRect));
    NSLog(@"MaxX: %f", charMaxX);
    NSLog(@"viewMaxX: %f", viewMaxX);
    
    // RIT DEBUG
    /*
    UIView *view = [[UIView alloc] initWithFrame:lastCharRect];
    view.backgroundColor = [UIColor colorWithRed:0.2f green:0.5f blue:0.2f alpha:0.4f];
    [textView addSubview:view];
    */
    // RIT DEBUG
    
    // Retrieve last paragraph
    NSString *text = textView.text;
    __block NSString *lastParagraph = nil;
    __block NSRange lastParagraphRange = {.location = 0, .length = 0};
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
     //options:NSStringEnumerationByParagraphs
                             options:NSStringEnumerationByParagraphs
     
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              
                              if (substringRange.length > 0) {
                                  
                                  lastParagraph = substring;
                                  lastParagraphRange = substringRange;
                              }
                          }];
    // RIT DEBUG
    NSLog(@"lastParagraph: %@ lastParagraphRange: %@", lastParagraph, NSStringFromRange(lastParagraphRange));
    // RIT DEBUG
    
    text = [text substringToIndex:lastParagraphRange.location];
    NSMutableParagraphStyle *paragraphStyle = [attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL];
    UIFont *font = [attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    // RIT DEBUG
    //NSLog(@"text: %@", text);
    // RIT DEBUG
    
    NSMutableArray* words = [[NSMutableArray alloc] initWithArray:[lastParagraph componentsSeparatedByString:@" "]];
    NSUInteger numWords = [words count];
    // RIT DEBUG
    NSLog(@"numWords: %d", numWords);
    // RIT DEBUG
    if ( numWords <= 1 ) return attributedText;
    NSAttributedString *suitableAttributedText = attributedText;
    for (int index = 0; index < 100; index++) {
        
        NSUInteger wordNum = index % (numWords - 1);
        NSString *word = words[wordNum];
        word = [NSString stringWithFormat:@"%@ ", word];
        words[wordNum] = word;
        NSMutableString *newLastParagraph = [NSMutableString stringWithString:words[0]];
        for (int i = 1; i < [words count]; i++) {
            
            [newLastParagraph appendFormat:@" %@", words[i]];
        }
        text = [NSString stringWithFormat:@"%@%@", text, newLastParagraph];
        NSAttributedString *newAttributedText = [[NSAttributedString alloc]
                                                 initWithString:text
                                                 attributes:
                                                 @{
                                                   NSFontAttributeName:font,
                                                   NSParagraphStyleAttributeName:paragraphStyle
                                                   }];
        textView.attributedText = newAttributedText;
        CGRect newLastCharRect = [self lastCharRectForTextView:textView andRange:NSMakeRange(0, [textView.textStorage length])];
        // RIT DEBUG
        NSLog(@"newLastCharRect: %@", NSStringFromCGRect(newLastCharRect));
        // RIT DEBUG
        if (lastCharRect.origin.y != newLastCharRect.origin.y) break;
        suitableAttributedText = newAttributedText;
        //NSLog(@"newLastParagraph: %@", newLastParagraph);
    }
    return suitableAttributedText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutText:(NSString *)text withTextView:(UITextView *)textView
{
    CGFloat appropriateLineSpacing;
    CGFloat lineSpacing = appropriateLineSpacing = lineSpacingInitialValue;
    CGFloat paragraphSpacing = paragraphSpacingInitialValue;
    NSAttributedString *attributedText = nil;
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:fontSizeInitialValue];
    CGSize viewSize = textView.frame.size;
    CGRect textRect;
    
    // stretch text to fill page rect
    attributedText = [self attributedText:text withLineSpacing:lineSpacing paragraphSpacing:paragraphSpacing andFont:font];
    textRect = [self rectForAttributedText:attributedText andSize:viewSize];
    
    while (CGRectGetHeight(textRect) < viewSize.height) {
        
        appropriateLineSpacing = lineSpacing;
        lineSpacing += lineSpacingStretchStep;
        attributedText = [self attributedText:text withLineSpacing:lineSpacing paragraphSpacing:paragraphSpacing andFont:font];
        textRect = [self rectForAttributedText:attributedText andSize:viewSize];
    }
    
    attributedText = [self attributedText:text withLineSpacing:appropriateLineSpacing paragraphSpacing:paragraphSpacing andFont:font];
    textRect = [self rectForAttributedText:attributedText andSize:viewSize];
    
    // shrink text to fill page rect
    // with paragraphSpacing property
    while (CGRectGetHeight(textRect) > viewSize.height && paragraphSpacing > 0) {
        
        paragraphSpacing -= paragraphSpacingShrinkStep;
        
        attributedText = [self attributedText:text withLineSpacing:appropriateLineSpacing paragraphSpacing:paragraphSpacing andFont:font];
        textRect = [self rectForAttributedText:attributedText andSize:viewSize];
    }
    
    // last paragraph string stretching
    NSCharacterSet *endSentenceSet = [NSCharacterSet characterSetWithCharactersInString:@".!?"];
    unichar lastChar = [_text characterAtIndex:_text.length - 1];
    if (![endSentenceSet characterIsMember:lastChar]) {
        
        //attributedText = [self lastParagraphStretchingForAttributedText:attributedText andViewSize:viewSize];
    }
    
    self.textView.attributedText = attributedText;
}


- (CGRect)rectForAttributedText:(NSAttributedString *)text andSize:(CGSize)size
{
    CGRect textRect;
    NSTextStorage *textStorege = [[NSTextStorage alloc] initWithAttributedString:text];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorege addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:size];
    [layoutManager addTextContainer:textContainer];
    CGRect viewRect = CGRectMake(0, 0, size.width, size.height);
    UITextView *textView = [[UITextView alloc] initWithFrame:viewRect textContainer:textContainer];
    [textView sizeToFit];
    CGRect textRect03 = textView.frame;
    textRect03 = CGRectIntegral(textRect03);
    //NSLog(@"[%@ %@] -- textRect03: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(textRect03));
    
    //textRect = (CGRectGetHeight(textRect01) > CGRectGetHeight(textRect02)) ? textRect01 : textRect02;
    textRect = textRect03;
    return textRect;
}

- (NSAttributedString *)attributedText:(NSString *)text withLineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing andFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.paragraphSpacing = paragraphSpacing;
    paragraphStyle.lineSpacing = lineSpacing;
    /*
    NSMutableAttributedString *attributedText = nil;
    attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
    [attributedText addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:NSMakeRange(0, [text length])];
     */
    
    NSAttributedString *newAttributedText = [[NSAttributedString alloc]
                                             initWithString:text
                                             attributes:
                                                @{
                                                  NSFontAttributeName:font,
                                                  NSParagraphStyleAttributeName:paragraphStyle
                                                  }];
    
    
    return newAttributedText;
}

- (IBAction)setTextButton:(UIButton *)sender {
}

/*
- (NSString*)string:(NSString*)sourceString reducedToConstrain:(CGSize)constrain maxHeight:(int)height withFont:(UIFont*)font
{
    if([sourceString sizeWithFont:font constrainedToSize:constrain lineBreakMode:NSLineBreakByWordWrapping].height <= height ) return sourceString;
    
    NSArray* words = [sourceString componentsSeparatedByString:@" "];
    NSInteger numWords = [words count];
    if( numWords <= 1 ) return sourceString;
    
    NSMutableString* str = [NSMutableString string];
    NSMutableString* strTemp = [NSMutableString string];
    NSString* strWordTemp = nil;
    NSInteger numWord = 0;
    Boolean addSpace = NO;
    for( NSString* strWord in words ) {
        numWord++;
        strWordTemp = [strWord stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([strWordTemp isEqualToString:@""] ) continue;
        [strTemp appendString:strWordTemp];
        if([strTemp sizeWithFont:font constrainedToSize:constrain lineBreakMode:NSLineBreakByWordWrapping].height <= height ) {
            addSpace = NO;
            if( numWord < numWords ) {
                
                [strTemp appendString:@" "];
                if( [strTemp sizeWithFont:font constrainedToSize:constrain lineBreakMode:NSLineBreakByWordWrapping].height > height ) {
                    [str appendString:strWordTemp];
                    break;
                }
                else addSpace = YES;
            }
            [str appendFormat:@"%@%@", strWordTemp, ( addSpace ? @" " : @"" )];
        }
        else break;
    }
    return str;
}
*/

/*
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}
*/

@end
