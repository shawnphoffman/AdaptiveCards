//
//  ACRInputTimeRenderer
//  ACRInputTimeRenderer.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACRInputTimeRenderer.h"
#import "ACRDateTextField.h"
#import "ACOHostConfigPrivate.h"
#import "ACOBaseCardElementPrivate.h"

@implementation ACRInputTimeRenderer

+ (ACRInputTimeRenderer *)getInstance
{
    static ACRInputTimeRenderer *singletonInstance = [[self alloc] init];
    return singletonInstance;
}

+ (ACRCardElementType)elemType
{
    return ACRTimeInput;
}

- (UIView *)render:(UIView *)viewGroup
          rootView:(ACRView *)rootView
            inputs:(NSMutableArray *)inputs
   baseCardElement:(ACOBaseCardElement *)acoElem
        hostConfig:(ACOHostConfig *)acoConfig;
{
    std::shared_ptr<HostConfig> config = [acoConfig getHostConfig];
    std::shared_ptr<BaseCardElement> elem = [acoElem element];
    std::shared_ptr<BaseInputElement> timeInput = std::dynamic_pointer_cast<BaseInputElement>(elem);
    ACRDateTextField *field = [[ACRDateTextField alloc] initWithTimeDateInput:timeInput dateStyle:NSDateFormatterNoStyle];

    if(viewGroup)
    {
        if(elem->GetHeight() == HeightType::Stretch){
            ACRColumnView *inputContainer = [[ACRColumnView alloc] init];
            [inputContainer addArrangedSubview: field];
            
            // Add a blank view so the input field doesnt grow as large as it can and so it keeps the same behavior as Android and UWP
            UIView *blankTrailingSpace = [[UIView alloc] init];
            [inputContainer addArrangedSubview:blankTrailingSpace];
            [inputContainer adjustHuggingForLastElement];
            
            [(UIStackView *)viewGroup addArrangedSubview: inputContainer];
        } else {
            [(UIStackView *)viewGroup addArrangedSubview: field];
        }
    }

    [inputs addObject:field];

    return field;
}

@end
