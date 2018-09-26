#pragma once

#include "pch.h"
#include "SharedAdaptiveCard.h"
#include "BaseActionElement.h"
#include "Enums.h"
#include "ActionParserRegistration.h"

namespace AdaptiveSharedNamespace {
class ShowCardAction : public BaseActionElement
{
public:
    ShowCardAction();

    Json::Value SerializeToJsonValue() const override;

    std::shared_ptr<AdaptiveSharedNamespace::AdaptiveCard> GetCard() const;
    void SetCard(const std::shared_ptr<AdaptiveSharedNamespace::AdaptiveCard>);

    void SetLanguage(const std::string& value);

    void GetResourceInformation(std::vector<RemoteResourceInformation>& resourceInfo) override;

private:
    void PopulateKnownPropertiesSet() override;

    std::shared_ptr<AdaptiveCard> m_card;
};

class ShowCardActionParser : public ActionElementParser
{
public:
    ShowCardActionParser() = default;
    ShowCardActionParser(const ShowCardActionParser&) = default;
    ShowCardActionParser(ShowCardActionParser&&) = default;
    ShowCardActionParser& operator=(const ShowCardActionParser&) = default;
    ShowCardActionParser& operator=(ShowCardActionParser&&) = default;
    virtual ~ShowCardActionParser() = default;

    std::shared_ptr<BaseActionElement> Deserialize(
        std::shared_ptr<ElementParserRegistration> elementParserRegistration,
        std::shared_ptr<ActionParserRegistration> actionParserRegistration,
        std::vector<std::shared_ptr<AdaptiveCardParseWarning>>& warnings,
        const Json::Value& value) override;

    std::shared_ptr<BaseActionElement> DeserializeFromString(
        std::shared_ptr<ElementParserRegistration> elementParserRegistration,
        std::shared_ptr<ActionParserRegistration> actionParserRegistration,
        std::vector<std::shared_ptr<AdaptiveCardParseWarning>>& warnings,
        const std::string& jsonString);
};
}
