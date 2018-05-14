/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.9
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class DateInput extends BaseInputElement {
  private transient long swigCPtr;
  private boolean swigCMemOwnDerived;

  protected DateInput(long cPtr, boolean cMemoryOwn) {
    super(AdaptiveCardObjectModelJNI.DateInput_SWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(DateInput obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        AdaptiveCardObjectModelJNI.delete_DateInput(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public DateInput() {
    this(AdaptiveCardObjectModelJNI.new_DateInput(), true);
  }

  public JsonValue SerializeToJsonValue() {
    return new JsonValue(AdaptiveCardObjectModelJNI.DateInput_SerializeToJsonValue(swigCPtr, this), true);
  }

  public String GetMax() {
    return AdaptiveCardObjectModelJNI.DateInput_GetMax(swigCPtr, this);
  }

  public void SetMax(String value) {
    AdaptiveCardObjectModelJNI.DateInput_SetMax(swigCPtr, this, value);
  }

  public String GetMin() {
    return AdaptiveCardObjectModelJNI.DateInput_GetMin(swigCPtr, this);
  }

  public void SetMin(String value) {
    AdaptiveCardObjectModelJNI.DateInput_SetMin(swigCPtr, this, value);
  }

  public String GetPlaceholder() {
    return AdaptiveCardObjectModelJNI.DateInput_GetPlaceholder(swigCPtr, this);
  }

  public void SetPlaceholder(String value) {
    AdaptiveCardObjectModelJNI.DateInput_SetPlaceholder(swigCPtr, this, value);
  }

  public String GetValue() {
    return AdaptiveCardObjectModelJNI.DateInput_GetValue(swigCPtr, this);
  }

  public void SetValue(String value) {
    AdaptiveCardObjectModelJNI.DateInput_SetValue(swigCPtr, this, value);
  }

  public static DateInput dynamic_cast(BaseCardElement baseCardElement) {
    long cPtr = AdaptiveCardObjectModelJNI.DateInput_dynamic_cast(BaseCardElement.getCPtr(baseCardElement), baseCardElement);
    return (cPtr == 0) ? null : new DateInput(cPtr, true);
  }

}
