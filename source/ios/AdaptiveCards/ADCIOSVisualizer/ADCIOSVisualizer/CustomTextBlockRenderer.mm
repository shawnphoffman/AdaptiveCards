//
//  CustomTextBlockRenderer
//  CustomTextBlockRenderer.mm
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "CustomTextBlockRenderer.h"
#import <AdaptiveCards/ACFramework.h>
#import <AdaptiveCards/SharedAdaptiveCard.h>
#import <AdaptiveCards/TextBlock.h>
#import <AdaptiveCards/ACRTextBlockRenderer.h>
#import <AdaptiveCards/ACOBaseCardElementPrivate.h>
#import <AdaptiveCards/ACRContentHoldingUIView.h>
#import <AdaptiveCards/MarkDownParser.h>
#import <AdaptiveCards/HostConfig.h>
#import <AdaptiveCards/ACOHostConfigPrivate.h>

@implementation CustomTextBlockRenderer

+ (CustomTextBlockRenderer *)getInstance
{
    static CustomTextBlockRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
            rootView:(ACRView *)rootView
            inputs:(NSArray *)inputs
   baseCardElement:(ACOBaseCardElement *)acoElem
        hostConfig:(ACOHostConfig *)acoConfig
{

    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<TextBlock> textBlockElement = std::static_pointer_cast<TextBlock>(elem);

    struct TextConfig textConfigForBlock =
    {
        .weight = textBlockElement->GetTextWeight(),
        .size = textBlockElement->GetTextSize(),
        .color = textBlockElement->GetTextColor(),
        .isSubtle = textBlockElement->GetIsSubtle(),
        .wrap = textBlockElement->GetWrap()
    };

    std::string textForBlock = textBlockElement->GetText();

    NSString* parsedString = nil;
    // MarkDownParser transforms text with MarkDown to a html string
    std::shared_ptr<MarkDownParser> markDownParser = std::make_shared<MarkDownParser>([ACOHostConfig getLocalizedDate:textBlockElement]);
    parsedString = [NSString stringWithCString:markDownParser->TransformToHtml().c_str() encoding:NSUTF8StringEncoding];

    // if correctly initialized, fonFamilyNames array is bigger than zero
    NSMutableString *fontFamilyName = [[NSMutableString alloc] initWithString:@"'"];
    [fontFamilyName appendString:[acoConfig.fontFamilyNames componentsJoinedByString:@"', '"]];
    [fontFamilyName appendString:@"'"];

    // Font and text size are applied as CSS style by appending it to the html string
    parsedString = [parsedString stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: %@; font-size:%dpx; font-weight: %d;}</style>",
                                                          fontFamilyName,
                                                          [acoConfig getTextBlockTextSize:textConfigForBlock.size],
                                                          [acoConfig getTextBlockFontWeight:textConfigForBlock.weight]]];
    // Convert html string to NSMutableAttributedString, NSAttributedString knows how to apply html tags
    NSData *htmlData = [parsedString dataUsingEncoding:NSUTF16StringEncoding];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};

    // Initializing NSMutableAttributedString for HTML rendering is very slow
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithData:htmlData options:options documentAttributes:nil error:nil];

    UILabel *lab = [[UILabel alloc] init]; // generate key for text map from TextBlock element's id
    // Set paragraph style such as line break mode and alignment
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = textConfigForBlock.wrap ? NSLineBreakByWordWrapping:NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = [ACOHostConfig getTextBlockAlignment:textBlockElement->GetHorizontalAlignment()];

    // Obtain text color to apply to the attributed string
    ACRContainerStyle style = viewGroup.style;
    ColorsConfig &colorConfig = (style == ACREmphasis)? [acoConfig getHostConfig]->containerStyles.emphasisPalette.foregroundColors:
                                                                           [acoConfig getHostConfig]->containerStyles.defaultPalette.foregroundColors;
    // Add paragraph style, text color, text weight as attributes to a NSMutableAttributedString, content.
    [content addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[ACOHostConfig getTextBlockColor:textConfigForBlock.color colorsConfig:colorConfig subtleOption:textConfigForBlock.isSubtle],} range:NSMakeRange(0, content.length)];
    lab.attributedText = content;

    lab.numberOfLines = int(textBlockElement->GetMaxLines());
    if(!lab.numberOfLines && !textBlockElement->GetWrap()){
        lab.numberOfLines = 1;
    }

    [viewGroup addArrangedSubview:lab];

    lab.backgroundColor = UIColor.lightGrayColor;

    lab.translatesAutoresizingMaskIntoConstraints = false;

    return lab;
}
@end
