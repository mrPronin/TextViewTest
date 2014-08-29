//
//  RITViewController.m
//  TextViewTest
//
//  Created by Pronin Alexander on 26.08.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITViewController.h"
#import <CoreText/CoreText.h>

@interface RITViewController ()

@end

@implementation RITViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setTextButton:(UIButton *)sender {
    
    /*
     NSString *text = @"В 1943-м году американские войска, дислоцированные в тропиках, подвергались серьезным атакам насекомых. Это было просто стихийным бедствием. Ни спать, ни есть комары не давали. Солдаты ходили вялые, мрачные, стреляли в молоко. Командование рапортовало о ситуации в центр, где к этому отнеслись серьезно и нашли двух экспертов для решения необычной задачи. Эксперты уселись изучать старые патенты и изобретения.\nУстав от длительных изысканий, Лайл, служащий Министерства Сельского Хозяйства, уже";
     */
    
     NSString *text = @"собрался домой. Кряхтя, поднялся из-за неудобного казённого стола и направился к шкафу, заваленному книгами и справочниками. Он уже убирал очередной том с собранием различных патентов в дальний угол, как вдруг отвлёкся на скрипнувшую дверь. Это вошёл его коллега и брат по несчастью, Уильям. Книга выпала из рук, раскрывшись на странице с затейливым рисунком. Лайл поправил очки и наклонился за книгой. Полнота делала этот процесс непростым.\n- Вот, смотри, - Лайл Гудхью ткнул толстым пальцем в описание патента номер 2170531.";
    
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:16];
    NSLog(@"Font line height: %f", font.lineHeight);
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.paragraphSpacing = 10.f;
    paragraphStyle.lineSpacing = 1.f;
    [attributedText addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [text length])];
    
    CGSize viewSize = self.textView.bounds.size;
    //viewSize.height -= font.lineHeight;
    //viewSize.height -= font.lineHeight * 2.5f;
    //viewSize.height -= 17;
    CGRect textRect;
    CGFloat lineSpacing = 1.f;
    
    while (CGRectGetHeight(textRect) < viewSize.height) {
        
        lineSpacing += 0.1f;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentJustified;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.paragraphSpacing = 10.f;
        paragraphStyle.lineSpacing = lineSpacing;
        [attributedText addAttribute:NSParagraphStyleAttributeName
                               value:paragraphStyle
                               range:NSMakeRange(0, [text length])];
        
        // first method
        /*
        textRect = [attributedText
                    boundingRectWithSize:CGSizeMake(viewSize.width, CGFLOAT_MAX)
                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                    context:nil];
        textRect = CGRectIntegral(textRect);
        NSLog(@"Method 01 for text rect: %@", NSStringFromCGRect(textRect));
        */
        
        // second method
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedText);
        CGSize targetSize = CGSizeMake(viewSize.width, CGFLOAT_MAX);
        CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedText length]), NULL, targetSize, NULL);
        CFRelease(framesetter);
        CGRect textRect2 = CGRectMake(0, 0, fitSize.width, fitSize.height);
        textRect = textRect2;
        NSLog(@"Method 02 for text rect: %@", NSStringFromCGRect(textRect2));
    }
    
    
    self.textView.attributedText = attributedText;
    
    NSLog(@"\n");
    NSLog(@"viewRect: %@", NSStringFromCGRect(self.textView.bounds));
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
