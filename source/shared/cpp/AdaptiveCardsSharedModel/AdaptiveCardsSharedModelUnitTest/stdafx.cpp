// stdafx.cpp : source file that includes just the standard includes
// AdaptiveCardsSharedModelUnitTest.pch will be the pre-compiled header
// stdafx.obj will contain the pre-compiled type information

#include "stdafx.h"

#pragma managed(push, off)
ExcludeFromCodeCoverage(BasicStringExclusion, L"*std::*");
ExcludeFromCodeCoverage(TestExclusion, L"AdaptiveCardsSharedModelUnitTest::*");
ExcludeSourceFromCodeCoverage(JsonCppExclusion, L"*\\jsoncpp.cpp");
ExcludeSourceFromCodeCoverage(JsonHeaderExclusion, L"*\\json.h");
#pragma managed(pop)
