//
//  ACRImageSetRenderer
//  ACRImageSetRenderer.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACRImageSetRenderer.h"
#import "ACRImageSetUICollectionView.h"
#import "ACOHostConfigPrivate.h"
#import "ACOBaseCardElementPrivate.h"
#import "ImageSet.h"
#import "SharedAdaptiveCard.h"

using namespace AdaptiveCards;

@implementation ACRImageSetRenderer

+ (ACRImageSetRenderer *)getInstance
{
    static ACRImageSetRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRImageSet;
}

- (UIView *)render:(UIView<ACRIContentHoldingView> *)viewGroup
          rootView:(ACRView *)rootView
            inputs:(NSMutableArray *)inputs
   baseCardElement:(ACOBaseCardElement *)acoElem
        hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<ImageSet>imgSetElem = std::dynamic_pointer_cast<ImageSet>(elem);
    ACRImageSetUICollectionView *view = [[ACRImageSetUICollectionView alloc] init:imgSetElem
                                                                   WithHostConfig:config
                                                                    WithSuperview:viewGroup
                                                                         rootView:rootView];
    [view registerClass:[UICollectionViewCell class]forCellWithReuseIdentifier:@"cellId"];

    [viewGroup addArrangedSubview:view];
    [viewGroup addConstraint:
     [NSLayoutConstraint constraintWithItem:view
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                     toItem:viewGroup
                                  attribute:NSLayoutAttributeLeading
                                 multiplier:1.0
                                   constant:0]];
    [viewGroup addConstraint:
     [NSLayoutConstraint constraintWithItem:view
                                  attribute:NSLayoutAttributeTrailing
                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                     toItem:viewGroup
                                  attribute:NSLayoutAttributeTrailing
                                 multiplier:1.0
                                   constant:0]];
    [view setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];

    return view;
}

@end
