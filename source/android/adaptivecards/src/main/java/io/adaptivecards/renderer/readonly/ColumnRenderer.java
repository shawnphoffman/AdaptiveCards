package io.adaptivecards.renderer.readonly;

import android.content.Context;
import android.graphics.Color;
import android.support.v4.app.FragmentManager;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import io.adaptivecards.objectmodel.ContainerStyle;
import io.adaptivecards.objectmodel.HeightType;
import io.adaptivecards.objectmodel.VerticalContentAlignment;
import io.adaptivecards.renderer.RenderedAdaptiveCard;
import io.adaptivecards.renderer.Util;
import io.adaptivecards.renderer.action.ActionElementRenderer;
import io.adaptivecards.renderer.actionhandler.ICardActionHandler;
import io.adaptivecards.renderer.inputhandler.IInputHandler;
import io.adaptivecards.objectmodel.BaseCardElement;
import io.adaptivecards.objectmodel.HostConfig;
import io.adaptivecards.objectmodel.Column;
import io.adaptivecards.renderer.BaseCardElementRenderer;
import io.adaptivecards.renderer.registration.CardRendererRegistration;

import java.util.Vector;
import java.util.Locale;

public class ColumnRenderer extends BaseCardElementRenderer
{
    protected ColumnRenderer()
    {
    }

    public static ColumnRenderer getInstance()
    {
        if (s_instance == null)
        {
            s_instance = new ColumnRenderer();
        }

        return s_instance;
    }

    @Override
    public View render(
            RenderedAdaptiveCard renderedCard,
            Context context,
            FragmentManager fragmentManager,
            ViewGroup viewGroup,
            BaseCardElement baseCardElement,
            ICardActionHandler cardActionHandler,
            HostConfig hostConfig,
            ContainerStyle containerStyle)
    {
        Column column;
        if (baseCardElement instanceof Column)
        {
            column = (Column) baseCardElement;
        }
        else if ((column = Column.dynamic_cast(baseCardElement)) == null)
        {
            throw new InternalError("Unable to convert BaseCardElement to FactSet object model.");
        }

        LinearLayout.LayoutParams layoutParams;
        setSpacingAndSeparator(context, viewGroup, column.GetSpacing(), column.GetSeparator(), hostConfig, false);

        ContainerStyle styleForThis = column.GetStyle().swigValue() == ContainerStyle.None.swigValue() ? containerStyle : column.GetStyle();
        LinearLayout returnedView = new LinearLayout(context);
        returnedView.setOrientation(LinearLayout.VERTICAL);

        LinearLayout verticalContentAlignmentLayout = new LinearLayout(context);
        verticalContentAlignmentLayout.setOrientation(LinearLayout.HORIZONTAL);
        verticalContentAlignmentLayout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        VerticalContentAlignment contentAlignment = column.GetVerticalContentAlignment();
        switch(contentAlignment)
        {
            case Center:
                verticalContentAlignmentLayout.setGravity(Gravity.CENTER_VERTICAL);
                break;
            case Bottom:
                verticalContentAlignmentLayout.setGravity(Gravity.BOTTOM);
                break;
            case Top:
            default:
                verticalContentAlignmentLayout.setGravity(Gravity.TOP);
                break;
        }
        returnedView.addView(verticalContentAlignmentLayout);

        if (!column.GetItems().isEmpty())
        {
            CardRendererRegistration.getInstance().render(renderedCard, context, fragmentManager, verticalContentAlignmentLayout, column, column.GetItems(), cardActionHandler, hostConfig, styleForThis);
        }
        if (styleForThis != containerStyle)
        {
            int padding = Util.dpToPixels(context, hostConfig.getSpacing().getPaddingSpacing());
            returnedView.setPadding(padding, padding, padding, padding);
            String color = styleForThis == containerStyle.Emphasis ?
                    hostConfig.getContainerStyles().getEmphasisPalette().getBackgroundColor() :
                    hostConfig.getContainerStyles().getDefaultPalette().getBackgroundColor();
            returnedView.setBackgroundColor(Color.parseColor(color));
        }

        String columnSize = column.GetWidth().toLowerCase(Locale.getDefault());
        long pixelWidth = column.GetPixelWidth();
        if (pixelWidth != 0)
        {
            layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
            layoutParams.width = Util.dpToPixels(context, pixelWidth);
            returnedView.setLayoutParams(layoutParams);
        }
        else
        {
            if (TextUtils.isEmpty(columnSize) || columnSize.equals(g_columnSizeStretch))
            {
                layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
                layoutParams.weight = 1;
                returnedView.setLayoutParams(layoutParams);
            }
            else if (columnSize.equals(g_columnSizeAuto))
            {
                layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT);
                returnedView.setLayoutParams(layoutParams);
            }
            else
            {
                try
                {
                    // I'm not sure what's going on here
                    float columnWeight = Float.parseFloat(columnSize);
                    layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
                    layoutParams.width = 0;
                    layoutParams.weight = columnWeight;
                    returnedView.setLayoutParams(layoutParams);
                }
                catch (NumberFormatException numFormatExcep)
                {
                    throw new IllegalArgumentException("Column Width (" + column.GetWidth() + ") is not a valid weight ('auto', 'stretch', <integer>).");
                }
            }
        }

        if (column.GetSelectAction() != null)
        {
            returnedView.setClickable(true);
            returnedView.setOnClickListener(new ActionElementRenderer.ButtonOnClickListener(renderedCard, column.GetSelectAction(), cardActionHandler));
        }

        viewGroup.addView(returnedView);
        return returnedView;
    }

    private static ColumnRenderer s_instance = null;
    private final String g_columnSizeAuto = "auto";
    private final String g_columnSizeStretch = "stretch";
}
