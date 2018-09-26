//
//  ADCIOSVisualizerTests.m
//  ADCIOSVisualizerTests
//
//  Created by jwoo on 6/2/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AdaptiveCards/ACFramework.h>
#import "AdaptiveCards/ACORemoteResourceInformationPrivate.h"


@interface ADCIOSVisualizerTests : XCTestCase

@end

@implementation ADCIOSVisualizerTests
{
    NSBundle *_mainBundle;
    NSString *_defaultHostConfigFile;
    ACOHostConfig *_defaultHostConfig;
}

- (void)setUp {
    [super setUp];
    _mainBundle = [NSBundle mainBundle];
    _defaultHostConfigFile = [NSString stringWithContentsOfFile:[_mainBundle pathForResource:@"sample" ofType:@"json"]
                              encoding:NSUTF8StringEncoding
                                 error:nil];
    if(_defaultHostConfigFile){
        ACOHostConfigParseResult *hostconfigParseResult = [ACOHostConfig fromJson:_defaultHostConfigFile resourceResolvers:nil];
        if(hostconfigParseResult.isValid){
            _defaultHostConfig = hostconfigParseResult.config;
        }
    }

    self.continueAfterFailure = NO;
}

- (NSArray<ACOAdaptiveCard *> *)prepCards:(NSArray<NSString *> *)fileNames
{
    NSMutableArray<ACOAdaptiveCard *> *cards = [[NSMutableArray alloc] init];
    for(NSString *fileName in fileNames){
        NSString *payload = [NSString stringWithContentsOfFile:[_mainBundle pathForResource:fileName ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
        ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
        if(cardParseResult.isValid) {
            [cards addObject:cardParseResult.card];
        }
    }
    return cards;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    _mainBundle = nil;
    _defaultHostConfigFile = nil;
    _defaultHostConfig = nil;
    [super tearDown];
}

- (void)testRemoteResouceInformation {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.

    NSString *payload = [NSString stringWithContentsOfFile:[_mainBundle pathForResource:@"FoodOrder" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];

    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    if(cardParseResult.isValid){
        NSArray<ACORemoteResourceInformation *> *remoteInformation = [cardParseResult.card remoteResourceInformation];
        XCTAssertTrue([remoteInformation count] == 3);
        NSArray<NSString *> *testStrings = @[
            @"http://contososcubademo.azurewebsites.net/assets/steak.jpg",
            @"http://contososcubademo.azurewebsites.net/assets/chicken.jpg",
            @"http://contososcubademo.azurewebsites.net/assets/tofu.jpg"
        ];
        unsigned int index = 0;
        for(ACORemoteResourceInformation *info in remoteInformation){
            XCTAssertTrue([[testStrings objectAtIndex:index++] isEqualToString:info.url.absoluteString]);
            XCTAssertTrue([@"image" isEqualToString:info.mimeType]);
        }
    }
}

- (void)testRelativeURLInformation {
    NSString *payload = [NSString stringWithContentsOfFile:[_mainBundle pathForResource:@"Image.ImageBaseUrl" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    if(cardParseResult.isValid){
        // host config base url is successfully parsed
        XCTAssertTrue([_defaultHostConfig.baseURL.absoluteString isEqualToString:@"https://pbs.twimg.com/profile_images/3647943215/"]);
    }
}

- (void)testACRTextView {
    NSString *payload = [NSString stringWithContentsOfFile:[_mainBundle pathForResource:@"Feedback" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    XCTAssertTrue(cardParseResult && cardParseResult.isValid);
    ACRRenderResult *renderResult = [ACRRenderer render:cardParseResult.card config:_defaultHostConfig widthConstraint:335];
    ACRTextView *acrTextView = (ACRTextView *)[renderResult.view viewWithTag:kACRTextView];
    XCTAssertNotNil(acrTextView);
    XCTAssertTrue([acrTextView.text length] == 0);
}

- (void)testChoiceSetInputCanGatherDefaultValues {
    NSString *payload = [NSString stringWithContentsOfFile:[_mainBundle pathForResource:@"Input.ChoiceSet" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSDictionary<NSString *, NSString *> *expectedValue = @{
        @"myColor" : @"1",
        @"myColor3" : @"1;3",
        @"myColor2" : @"1",
        @"myColor4" : @"1"
        };
    NSData *expectedData = [NSJSONSerialization dataWithJSONObject:expectedValue options:NSJSONWritingPrettyPrinted error:nil];
    NSString *expectedString = [[NSString alloc] initWithData:expectedData encoding:NSUTF8StringEncoding];
    ACOAdaptiveCardParseResult *cardParseResult = [ACOAdaptiveCard fromJson:payload];
    if(cardParseResult.isValid){
        [ACRRenderer render:cardParseResult.card config:_defaultHostConfig widthConstraint:100.0];
        // manually call input gather function
        NSData *output = [cardParseResult.card inputs];
        NSString *str = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
        XCTAssertTrue([str isEqualToString:expectedString]);
    }
}

- (void)testPerformanceOnComplicatedCards {
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"Restaurant", @"FoodOrder", @"ActivityUpdate"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnRestaurant {
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"Restaurant"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnFoodOrder {
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"FoodOrder"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnActivityUpdate {
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"ActivityUpdate"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlock {
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.MaxLines", @"TextBlock.Wrap", @"TextBlock.HorizontalAlignment"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockColor {
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.Color"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockDateTimeFormatting{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.DateTimeFormatting"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockHorizontalAlignment{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.HorizontalAlignment"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockSubtle{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.IsSubtle"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockLists{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.Lists"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockMarkDown{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.Markdown"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockMaxLines{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.MaxLines"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockSize{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.Size"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockSpacing{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.Spacing"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockWeight{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.Weight"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsTextBlockWrap{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"TextBlock.Wrap"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsImage{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"Image.Size", @"Image.Spacing", @"Image.Style", @"Image"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsColumnSet{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"ColumnSet.Spacing", @"ColumnSet"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

- (void)testPerformanceOnSimpleCardsColumn{
    // This is an example of a performance test case.
    NSArray<NSString *> *payloadNames = @[@"Column.Size.Ratio", @"Column.Spacing", @"Column.Width.Ratio", @"Column.Width", @"Column"];
    NSArray<ACOAdaptiveCard *> *cards = [self prepCards:payloadNames];
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        for(ACOAdaptiveCard *card in cards) {
            [ACRRenderer render:card config:self->_defaultHostConfig widthConstraint:320.0];
        }
    }];
}

@end
