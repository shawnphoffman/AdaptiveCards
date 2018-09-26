//
//  ACRActionSetRenderer
//  ACRActionSetRenderer.mm
//
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "ACRBaseActionElementRenderer.h"
#import "ACRActionSetRenderer.h"
#import "ACRRegistration.h"
#import "ACOAdaptiveCardPrivate.h"
#import "ACOHostConfigPrivate.h"
#import "ACRColumnSetView.h"
#import "ACRColumnView.h"
#import "ACRContentHoldingUIScrollView.h"
#import "ACOBaseActionElementPrivate.h"
#import "ACRIContentHoldingView.h"
@implementation ACRActionSetRenderer

+ (ACRActionSetRenderer *)getInstance
{
    static ACRActionSetRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

- (UIView *)renderButtons:(ACRView *)rootView
                   inputs:(NSMutableArray *)inputs
                superview:(UIView<ACRIContentHoldingView> *)superview
                     card:(ACOAdaptiveCard *)card
               hostConfig:(ACOHostConfig *)config
{
    ACRRegistration *reg = [ACRRegistration getInstance];
    UIView<ACRIContentHoldingView> *childview = nil;
    NSDictionary<NSString *, NSNumber*> *attributes =
    @{@"spacing":[NSNumber numberWithInt:[config getHostConfig]->actions.buttonSpacing],
      @"distribution":[NSNumber numberWithInt:UIStackViewDistributionFillProportionally] };
    
    if(ActionsOrientation::Horizontal == [config getHostConfig]->actions.actionsOrientation){
        childview = [[ACRColumnSetView alloc] initWithFrame:CGRectMake(0, 0, superview.frame.size.width, superview.frame.size.height) attributes:attributes];
    }
    else{
        childview = [[ACRColumnView alloc] initWithFrame:CGRectMake(0, 0, superview.frame.size.width, superview.frame.size.height) attributes:attributes];
    }
    
    ACOBaseActionElement *acoElem = [[ACOBaseActionElement alloc] init];
    ACRContentHoldingUIScrollView *containingView = [[ACRContentHoldingUIScrollView alloc] init];
    [superview addArrangedSubview:containingView];
    float accumulatedWidth = 0, accumulatedHeight = 0, spacing = [config getHostConfig]->actions.buttonSpacing, maxWidth = 0, maxHeight = 0;
    std::vector<std::shared_ptr<BaseActionElement>> elems = [card card]->GetActions();
    for(const auto &elem:elems){
        ACRBaseActionElementRenderer *actionRenderer =
        [reg getActionRenderer:[NSNumber numberWithInt:(int)elem->GetElementType()]];
        
        if(actionRenderer == nil){
            NSLog(@"Unsupported card action type:%d\n", (int) elem->GetElementType());
            continue;
        }
        
        [acoElem setElem:elem];
        UIButton *button = [actionRenderer renderButton:rootView inputs:inputs superview:superview baseActionElement:acoElem hostConfig:config];
        
        accumulatedWidth += [button intrinsicContentSize].width;
        accumulatedHeight += [button intrinsicContentSize].height;
        maxWidth = MAX(maxWidth, [button intrinsicContentSize].width);
        maxHeight = MAX(maxHeight, [button intrinsicContentSize].height);
        
        [childview addArrangedSubview:button];
    }
    
    float contentWidth = accumulatedWidth, contentHeight = accumulatedHeight;
    [childview adjustHuggingForLastElement];
    if(ActionsOrientation::Horizontal == [config getHostConfig]->actions.actionsOrientation){
        contentWidth += (elems.size() - 1) * spacing;
        contentHeight = maxHeight;
    } else {
        contentHeight += (elems.size() - 1) * spacing;
        contentWidth = maxWidth;
    }
    childview.frame = CGRectMake(0, 0, contentWidth, contentHeight);
    containingView.frame = CGRectMake(0, 0, superview.frame.size.width, contentHeight + spacing);
    containingView.translatesAutoresizingMaskIntoConstraints = NO;
    [containingView addSubview:childview];
    [NSLayoutConstraint constraintWithItem:containingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:childview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:containingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:childview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:containingView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:childview attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0].active = YES;
    [NSLayoutConstraint constraintWithItem:containingView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:childview attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0].active = YES;
    NSLayoutConstraint *hConstraint = [NSLayoutConstraint constraintWithItem:childview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:containingView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    NSLayoutConstraint *vConstraint = [NSLayoutConstraint constraintWithItem:childview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:containingView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    
    hConstraint.active = YES;
    vConstraint.active = YES;
    
    if(ActionsOrientation::Horizontal == [config getHostConfig]->actions.actionsOrientation){
        hConstraint.priority = UILayoutPriorityDefaultLow;
        if(contentWidth > superview.frame.size.width){
            containingView.showsHorizontalScrollIndicator = YES;
        } else
        {
            if([config getHostConfig]->actions.actionAlignment == ActionAlignment::Stretch){
                [NSLayoutConstraint constraintWithItem:containingView attribute:NSLayoutAttributeWidth
                                             relatedBy:NSLayoutRelationEqual toItem:childview
                                             attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0].active = YES;
            }
        }
    } else {
        vConstraint.priority = UILayoutPriorityDefaultLow;
    }
    return containingView;
}

@end
