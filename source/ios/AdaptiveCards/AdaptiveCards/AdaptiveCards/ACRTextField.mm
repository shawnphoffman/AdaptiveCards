//
//  ACRTextField
//  ACRTextField.mm
//
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ACOBaseCardElementPrivate.h"
#import "ACRTextField.h"
#import "TextInput.h"


@implementation ACRTextField

- (BOOL)validate:(NSError **)error
{
    if(self.isRequired && !self.hasText)
    {
        if(error)
        {
            *error = [NSError errorWithDomain:ACRInputErrorDomain code:ACRInputErrorValueMissing userInfo:nil];
        }
        return NO;
    }
    else
        return YES;
}

- (void)getInput:(NSMutableDictionary *)dictionary
{
    dictionary[self.id] = self.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return YES;
}

- (void)dismissNumPad
{
    [self resignFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(!_maxLength){
        return YES;
    }
    
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= _maxLength;
}
@end
