#pragma once

void GetMediaPosterAsImage(
    ABI::AdaptiveNamespace::IAdaptiveRenderContext* renderContext,
    ABI::AdaptiveNamespace::IAdaptiveRenderArgs* renderArgs,
    ABI::AdaptiveNamespace::IAdaptiveMedia * adaptiveMedia,
    ABI::Windows::UI::Xaml::Controls::IImage ** posterImage);

void CreatePosterContainerWithPlayButton(
    ABI::Windows::UI::Xaml::Controls::IImage* posterImage,
    ABI::AdaptiveNamespace::IAdaptiveRenderContext* renderContext,
    ABI::AdaptiveNamespace::IAdaptiveRenderArgs* renderArgs,
    ABI::Windows::UI::Xaml::IUIElement ** posterContainer);

void GetMediaSource(
    ABI::AdaptiveNamespace::IAdaptiveHostConfig* hostConfig,
    ABI::AdaptiveNamespace::IAdaptiveMedia* adaptiveMedia,
    ABI::Windows::Foundation::IUriRuntimeClass** mediaSourceUrl,
    HSTRING * mimeType);

HRESULT HandleMediaClick(
    ABI::AdaptiveNamespace::IAdaptiveRenderContext* renderContext,
    ABI::AdaptiveNamespace::IAdaptiveMedia* adaptiveMedia,
    ABI::Windows::UI::Xaml::Controls::IMediaElement* mediaElement,
    ABI::Windows::UI::Xaml::IUIElement* posterContainer,
    ABI::Windows::Foundation::IUriRuntimeClass* mediaSourceUrl,
    HSTRING mimeType,
    ABI::AdaptiveNamespace::IAdaptiveMediaEventInvoker* mediaInvoker);