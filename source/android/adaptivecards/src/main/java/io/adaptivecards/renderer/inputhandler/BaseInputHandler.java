package io.adaptivecards.renderer.inputhandler;

import android.view.View;
import io.adaptivecards.objectmodel.BaseInputElement;

public abstract class BaseInputHandler implements IInputHandler
{
    public BaseInputHandler(BaseInputElement baseInputElement)
    {
        m_baseInputElement = baseInputElement;
    }

    public void setView(View view)
    {
        m_view = view;
    }

    public BaseInputElement getBaseInputElement()
    {
        return m_baseInputElement;
    }

    public String getId()
    {
        return m_baseInputElement.GetId();
    }

    public abstract void setInput(String input);

    protected BaseInputElement m_baseInputElement = null;
    protected View m_view = null;

}
