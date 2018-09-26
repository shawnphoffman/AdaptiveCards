//
//  ACRFactSetRenderer
//  ACRFactSetRenderer.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//
#import "ACRTextBlockRenderer.h"
#import "ACRContentHoldingUIView.h"
#import "ACRFactSetRenderer.h"
#import "ACRSeparator.h"
#import "ACRColumnSetView.h"
#import "FactSet.h"
#import "ACOHostConfigPrivate.h"
#import "ACOBaseCardElementPrivate.h"
#import "ACRUILabel.h"

@implementation ACRFactSetRenderer

+ (ACRFactSetRenderer *)getInstance
{
    static ACRFactSetRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRFactSet;
}

+ (ACRUILabel *)buildLabel:(NSString *)text
                 superview:(UIView<ACRIContentHoldingView> *)superview
                hostConfig:(ACOHostConfig *)acoConfig
                textConfig:(TextConfig const &)textConfig
            containerStyle:(ACRContainerStyle)style
                 elementId:(NSString *)elementId
                  rootView:(ACRView *)rootView
                   element:(std::shared_ptr<BaseCardElement> const &)element
{
    ACRUILabel *lab = [[ACRUILabel alloc] initWithFrame:CGRectMake(0,0,superview.frame.size.width, 0)];
    lab.translatesAutoresizingMaskIntoConstraints = NO;
    lab.style = style;
    lab.editable = NO;
    lab.textContainer.lineFragmentPadding = 0;
    lab.textContainerInset = UIEdgeInsetsZero;
    lab.layoutManager.usesFontLeading = false;
    lab.tag = eACRUIFactSetTag;

    NSMutableAttributedString *content = nil;
    if(rootView){
        std::shared_ptr<FactSet> fctSet = std::dynamic_pointer_cast<FactSet>(element);
        NSMutableDictionary *textMap = [rootView getTextMap];
        NSDictionary* data = textMap[elementId];
        NSData *htmlData = data[@"html"];
        NSDictionary *options = data[@"options"];
        NSDictionary *descriptor = data[@"descriptor"];
        NSString *text = data[@"nonhtml"];

        std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
        // Initializing NSMutableAttributedString for HTML rendering is very slow
        if(htmlData){
            content = [[NSMutableAttributedString alloc] initWithData:htmlData options:options documentAttributes:nil error:nil];
            // Drop newline char
            [content deleteCharactersInRange:NSMakeRange([content length] -1, 1)];
        } else {
            // if html rendering is skipped, remove p tags from both ends (<p>, </p>)
            content = [[NSMutableAttributedString alloc] initWithString:text attributes:descriptor];
            [content deleteCharactersInRange:NSMakeRange(0, 3)];
            [content deleteCharactersInRange:NSMakeRange([content length] -4, 4)];
        }
        // Set paragraph style such as line break mode and alignment
        lab.textContainer.lineBreakMode = textConfig.wrap ? NSLineBreakByWordWrapping:NSLineBreakByTruncatingTail;

        // Obtain text color to apply to the attributed string
        ACRContainerStyle style = lab.style;
        ColorsConfig &colorConfig = (style == ACREmphasis) ? config->containerStyles.emphasisPalette.foregroundColors :
                                                             config->containerStyles.defaultPalette.foregroundColors;

        // Add paragraph style, text color, text weight as attributes to a NSMutableAttributedString, content.
        [content addAttributes:@{NSForegroundColorAttributeName:
                                   [ACOHostConfig getTextBlockColor:textConfig.color colorsConfig:colorConfig
                                       subtleOption:textConfig.isSubtle],
                                 NSStrokeWidthAttributeName:
                                   [ACOHostConfig getTextStrokeWidthForWeight:textConfig.weight]}
                         range:NSMakeRange(0, content.length)];
        lab.attributedText = content;
        std::string ID = element->GetId();
        std::size_t idx = ID.find_last_of('_');
        if(std::string::npos != idx){
            element->SetId(ID.substr(0, idx));
        }
    }

    lab.textContainer.maximumNumberOfLines = textConfig.wrap ? 0 : 1;

    return lab;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
          rootView:(ACRView *)rootView
            inputs:(NSMutableArray *)inputs
   baseCardElement:(ACOBaseCardElement *)acoElem
        hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<FactSet> fctSet = std::dynamic_pointer_cast<FactSet>(elem);

    ACRContainerStyle style = [viewGroup style];
    NSString *key = [NSString stringWithCString:elem->GetId().c_str() encoding:[NSString defaultCStringEncoding]];
    key = [key stringByAppendingString:@"*"];
    int rowFactId = 0;

    UIStackView *titleStack = [[UIStackView alloc] init];
    titleStack.axis = UILayoutConstraintAxisVertical;

    UIStackView *valueStack = [[UIStackView alloc] init];
    valueStack.axis = UILayoutConstraintAxisVertical;

    ACRColumnSetView *factSetWrapperView = [[ACRColumnSetView alloc] init];
    [factSetWrapperView addArrangedSubview:titleStack];
    [ACRSeparator renderSeparationWithFrame:CGRectMake(0, 0, config->factSet.spacing, config->factSet.spacing) superview:factSetWrapperView axis:UILayoutConstraintAxisHorizontal];
    [factSetWrapperView addArrangedSubview:valueStack];
    [ACRSeparator renderSeparationWithFrame:CGRectMake(0, 0, config->factSet.spacing, config->factSet.spacing) superview:factSetWrapperView axis:UILayoutConstraintAxisHorizontal];

    [factSetWrapperView adjustHuggingForLastElement];

    for(auto fact :fctSet->GetFacts())
    {
        NSString *title = [NSString stringWithCString:fact->GetTitle().c_str() encoding:NSUTF8StringEncoding];
        ACRUILabel *titleLab = [ACRFactSetRenderer buildLabel:title
                                                    superview:viewGroup
                                                   hostConfig:acoConfig
                                                   textConfig:config->factSet.title
                                               containerStyle:style
                                                    elementId:[key stringByAppendingString:[[NSNumber numberWithInt:rowFactId++] stringValue]]
                                                     rootView:rootView
                                                      element:elem];
        [titleLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [titleLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [titleLab setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        if (config->factSet.title.maxWidth) {
            NSLayoutConstraint *constraintForTitleLab = [NSLayoutConstraint constraintWithItem:titleLab attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:config->factSet.title.maxWidth];
            constraintForTitleLab.active = YES;
            constraintForTitleLab.priority = UILayoutPriorityRequired;
        }
        NSString *value = [NSString stringWithCString:fact->GetValue().c_str() encoding:NSUTF8StringEncoding];
        ACRUILabel *valueLab = [ACRFactSetRenderer buildLabel:value
                                                    superview:viewGroup
                                                   hostConfig:acoConfig
                                                   textConfig:config->factSet.value
                                               containerStyle:style
                                                    elementId:[key stringByAppendingString:[[NSNumber numberWithInt:rowFactId++] stringValue]]
                                                     rootView:rootView
                                                      element:elem];
        [valueLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [titleStack addArrangedSubview:titleLab];
        [valueStack addArrangedSubview:valueLab];
        [NSLayoutConstraint constraintWithItem:valueLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:titleLab attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0].active = YES;
    }

    [viewGroup addArrangedSubview:factSetWrapperView];

    return factSetWrapperView;
}
@end
