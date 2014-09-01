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

@end

@implementation RITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
     _text = @"собрался домой. Кряхтя, поднялся из-за неудобного казённого стола и направился к шкафу, заваленному книгами и справочниками. Он уже убирал очередной том с собранием различных патентов в дальний угол, как вдруг отвлёкся на скрипнувшую дверь. Это вошёл его коллега и брат по несчастью, Уильям. Книга выпала из рук, раскрывшись на странице с затейливым рисунком. Лайл поправил очки и наклонился за книгой. Полнота делала этот процесс непростым.\n- Вот, смотри, - Лайл Гудхью ткнул толстым пальцем в описание патента номер 2170531.";
     */
    
    _text = @"В 1943-м году американские войска, дислоцированные в тропиках, подвергались серьезным атакам насекомых. Это было просто стихийным бедствием. Ни спать, ни есть комары не давали. Солдаты ходили вялые, мрачные, стреляли в молоко. Командование рапортовало о ситуации в центр, где к этому отнеслись серьезно и нашли двух экспертов для решения необычной задачи. Эксперты уселись изучать старые патенты и изобретения.\nУстав от длительных изысканий, Лайл, служащий Министерства Сельского Хозяйства, уже";
    
    //_textView.layoutManager.showsInvisibleCharacters = YES;
    
    [self layoutAttributedText:_text withSize:self.textView.frame.size];
    
    //[_textView.layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, [_textView.textStorage length])];
    [_textView.layoutManager ensureLayoutForTextContainer:_textView.textContainer];
    
    // RIT DEBUG
    //NSLog(@"[%@ %@] -- hasNonContiguousLayout: %d", [self class], NSStringFromSelector(_cmd), _textView.layoutManager.hasNonContiguousLayout);
    // RIT DEBUG
    
    NSCharacterSet *endSentenceSet = [NSCharacterSet characterSetWithCharactersInString:@".!?"];
    NSRange lastCharRange = NSMakeRange([_text length] - 1, 1);
    NSString *lastChar = [_text substringWithRange:lastCharRange];
    if ([lastChar isEqualToString:@"."]) {
        
    }
    
    [self lastParagraphForString:_text withTextView:_textView];
}

- (void)lastParagraphForString:(NSString *)text withTextView:(UITextView *)textView
{
    
    UITextPosition *Pos2 = [textView positionFromPosition: textView.endOfDocument offset: 0];
    UITextPosition *Pos1 = [textView positionFromPosition: textView.endOfDocument offset: -3];
    
    UITextRange *range = [textView textRangeFromPosition:Pos1 toPosition:Pos2];
    
    CGRect result1 = [textView firstRectForRange:(UITextRange *)range ];
    
    NSLog(@"%f, %f", result1.origin.x, result1.origin.y);
    
    UIView *view1 = [[UIView alloc] initWithFrame:result1];
    view1.backgroundColor = [UIColor colorWithRed:0.2f green:0.5f blue:0.2f alpha:0.4f];
    [textView addSubview:view1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutAttributedText:(NSString *)text withSize:(CGSize)size
{
    CGFloat appropriateLineSpacing;
    CGFloat lineSpacing = appropriateLineSpacing = lineSpacingInitialValue;
    CGFloat paragraphSpacing = paragraphSpacingInitialValue;
    NSMutableAttributedString *attributedText = nil;
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:fontSizeInitialValue];
    CGSize viewSize = size;
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

- (NSMutableAttributedString *)attributedText:(NSString *)text withLineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing andFont:(UIFont *)font
{
    NSMutableAttributedString *attributedText = nil;
    NSMutableParagraphStyle *paragraphStyle = nil;
    attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
    paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.paragraphSpacing = paragraphSpacing;
    paragraphStyle.lineSpacing = lineSpacing;
    [attributedText addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:NSMakeRange(0, [text length])];
    
    return attributedText;
}

- (IBAction)setTextButton:(UIButton *)sender {
    [self lastParagraphForString:_text withTextView:_textView];
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
