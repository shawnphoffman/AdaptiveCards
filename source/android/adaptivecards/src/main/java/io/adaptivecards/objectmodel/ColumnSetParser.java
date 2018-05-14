/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.9
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class ColumnSetParser extends BaseCardElementParser {
  private transient long swigCPtr;
  private boolean swigCMemOwnDerived;

  protected ColumnSetParser(long cPtr, boolean cMemoryOwn) {
    super(AdaptiveCardObjectModelJNI.ColumnSetParser_SWIGSmartPtrUpcast(cPtr), true);
    swigCMemOwnDerived = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(ColumnSetParser obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwnDerived) {
        swigCMemOwnDerived = false;
        AdaptiveCardObjectModelJNI.delete_ColumnSetParser(swigCPtr);
      }
      swigCPtr = 0;
    }
    super.delete();
  }

  public BaseCardElement Deserialize(ElementParserRegistration elementParserRegistration, ActionParserRegistration actionParserRegistration, JsonValue root) {
    long cPtr = AdaptiveCardObjectModelJNI.ColumnSetParser_Deserialize(swigCPtr, this, ElementParserRegistration.getCPtr(elementParserRegistration), elementParserRegistration, ActionParserRegistration.getCPtr(actionParserRegistration), actionParserRegistration, JsonValue.getCPtr(root), root);
    return (cPtr == 0) ? null : new BaseCardElement(cPtr, true);
  }

  public BaseCardElement DeserializeFromString(ElementParserRegistration elementParserRegistration, ActionParserRegistration actionParserRegistration, String jsonString) {
    long cPtr = AdaptiveCardObjectModelJNI.ColumnSetParser_DeserializeFromString(swigCPtr, this, ElementParserRegistration.getCPtr(elementParserRegistration), elementParserRegistration, ActionParserRegistration.getCPtr(actionParserRegistration), actionParserRegistration, jsonString);
    return (cPtr == 0) ? null : new BaseCardElement(cPtr, true);
  }

  public ColumnSetParser() {
    this(AdaptiveCardObjectModelJNI.new_ColumnSetParser(), true);
  }

}
