//
//  RITCoreTextViewController.m
//  TextViewTest
//
//  Created by Aleksandr Pronin on 03.09.14.
//  Copyright (c) 2014 Pronin Alexander. All rights reserved.
//

#import "RITCoreTextViewController.h"

/*
const CGFloat lineSpacingStretchStep = 1.f;
const CGFloat lineSpacingInitialValue = 0;
const CGFloat paragraphSpacingInitialValue = 10.f;
const CGFloat paragraphSpacingShrinkStep = 1.f;
const CGFloat fontSizeInitialValue = 16.f;
*/

@interface RITCoreTextViewController ()

@end

@implementation RITCoreTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"[%@ %@] -- frame: %@ bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"[%@ %@] -- frame: %@ bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"[%@ %@] -- frame: %@ bounds: %@", [self class], NSStringFromSelector(_cmd), NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutText
{
    //const CGFloat lineSpacingStretchStep = 1.f;
    const CGFloat lineSpacingInitialValue = 0;
    const CGFloat paragraphSpacingInitialValue = 20.f;
    //const CGFloat paragraphSpacingShrinkStep = 1.f;
    const CGFloat fontSizeInitialValue = 18.f;
    NSString *text = @"В 1943-м году американские войска, дислоцированные в тропиках, подвергались серьезным атакам насекомых. Это было просто стихийным бедствием. Ни спать, ни есть комары не давали. Солдаты ходили вялые, мрачные, стреляли в молоко. Командование рапортовало о ситуации в центр, где к этому отнеслись серьезно и нашли двух экспертов для решения необычной задачи. Эксперты уселись изучать старые патенты и изобретения.\nУстав от длительных изысканий, Лайл, служащий Министерства Сельского Хозяйства, уже";
    CGFloat appropriateLineSpacing;
    CGFloat lineSpacing = appropriateLineSpacing = lineSpacingInitialValue;
    CGFloat paragraphSpacing = paragraphSpacingInitialValue;
    NSAttributedString *attributedText = nil;
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:fontSizeInitialValue];
    attributedText = [self attributedText:text withLineSpacing:lineSpacing paragraphSpacing:paragraphSpacing andFont:font];
    self.textView.attributedString = attributedText;
}

- (NSAttributedString *)attributedText:(NSString *)text withLineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing andFont:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentJustified;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.paragraphSpacing = paragraphSpacing;
    paragraphStyle.lineSpacing = lineSpacing;
    
    NSAttributedString *newAttributedText = [[NSAttributedString alloc]
                                             initWithString:text
                                             attributes:
                                             @{
                                               NSFontAttributeName:font,
                                               NSParagraphStyleAttributeName:paragraphStyle
                                               }];
    
    
    return newAttributedText;
}

- (IBAction)actionBarButton:(UIBarButtonItem *)sender {
    
    [self layoutText];
    
    //NSLog(@"frame: %@ bounds: %@", NSStringFromCGRect(_textView.frame), NSStringFromCGRect(_textView.bounds));
}

@end
