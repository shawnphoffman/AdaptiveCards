/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.9
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class NumberInput extends BaseInputElement {
  private transient long swigCPtr;
  private boolean swigCMemOwnDerived;

  protected NumberInput(long cPtr, boolean cMemoryOwn) {
    super(AdaptiveCardObjectModelJNI.NumberInput_SWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(NumberInput obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        AdaptiveCardObjectModelJNI.delete_NumberInput(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public NumberInput() {
    this(AdaptiveCardObjectModelJNI.new_NumberInput(), true);
  }

  public JsonValue SerializeToJsonValue() {
    return new JsonValue(AdaptiveCardObjectModelJNI.NumberInput_SerializeToJsonValue(swigCPtr, this), true);
  }

  public String GetPlaceholder() {
    return AdaptiveCardObjectModelJNI.NumberInput_GetPlaceholder(swigCPtr, this);
  }

  public void SetPlaceholder(String value) {
    AdaptiveCardObjectModelJNI.NumberInput_SetPlaceholder(swigCPtr, this, value);
  }

  public int GetValue() {
    return AdaptiveCardObjectModelJNI.NumberInput_GetValue(swigCPtr, this);
  }

  public void SetValue(int value) {
    AdaptiveCardObjectModelJNI.NumberInput_SetValue(swigCPtr, this, value);
  }

  public int GetMax() {
    return AdaptiveCardObjectModelJNI.NumberInput_GetMax(swigCPtr, this);
  }

  public void SetMax(int value) {
    AdaptiveCardObjectModelJNI.NumberInput_SetMax(swigCPtr, this, value);
  }

  public int GetMin() {
    return AdaptiveCardObjectModelJNI.NumberInput_GetMin(swigCPtr, this);
  }

  public void SetMin(int value) {
    AdaptiveCardObjectModelJNI.NumberInput_SetMin(swigCPtr, this, value);
  }

  public static NumberInput dynamic_cast(BaseCardElement baseCardElement) {
    long cPtr = AdaptiveCardObjectModelJNI.NumberInput_dynamic_cast(BaseCardElement.getCPtr(baseCardElement), baseCardElement);
    return (cPtr == 0) ? null : new NumberInput(cPtr, true);
  }

}
