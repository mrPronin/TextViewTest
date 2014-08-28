//
//  RITViewController.m
//  TextViewTest
//
//  Created by Pronin Alexander on 26.08.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITViewController.h"

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
    
    NSString *text = @"В 1943-м году американские войска, дислоцированные в тропиках, подвергались серьезным атакам насекомых. Это было просто стихийным бедствием. Ни спать, ни есть комары не давали. Солдаты ходили вялые, мрачные, стреляли в молоко. Командование рапортовало о ситуации в центр, где к этому отнеслись серьезно и нашли двух экспертов для решения необычной задачи. Эксперты уселись изучать старые патенты и изобретения.\nУстав от длительных изысканий, Лайл, служащий Министерства Сельского Хозяйства, уже";
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:17]}];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.paragraphSpacing = 20.f;
    paragraphStyle.lineSpacing = 5.f;
    [attributedText addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [text length])];
    self.textView.attributedText = attributedText;
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
