#pragma once

#include "AdaptiveCards.Rendering.Uwp.h"
#include "Enums.h"
#include "HostConfig.h"

AdaptiveNamespaceStart
    class AdaptiveMediaConfig :
        public Microsoft::WRL::RuntimeClass<
        Microsoft::WRL::RuntimeClassFlags<Microsoft::WRL::RuntimeClassType::WinRtClassicComMix>,
        ABI::AdaptiveNamespace::IAdaptiveMediaConfig>
    {
        AdaptiveRuntime(AdaptiveMediaConfig)

    public:
        HRESULT RuntimeClassInitialize() noexcept;
        HRESULT RuntimeClassInitialize(MediaConfig mediaConfig) noexcept;

        IFACEMETHODIMP get_DefaultPoster(_Out_ HSTRING* defaultPoster);
        IFACEMETHODIMP put_DefaultPoster(_In_ HSTRING defaultPoster);

        IFACEMETHODIMP get_PlayButton(_Out_ HSTRING* playButton);
        IFACEMETHODIMP put_PlayButton(_In_ HSTRING playButton);

        IFACEMETHODIMP get_AllowInlinePlayback(_Out_ boolean* AllowInlinePlayback);
        IFACEMETHODIMP put_AllowInlinePlayback(_In_ boolean AllowInlinePlayback);

    private:
        Microsoft::WRL::Wrappers::HString m_defaultPoster;
        Microsoft::WRL::Wrappers::HString m_playButton;
        boolean m_allowInlinePlayback;
    };
    ActivatableClass(AdaptiveMediaConfig);
AdaptiveNamespaceEnd
