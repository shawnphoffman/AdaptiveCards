/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.9
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public enum HorizontalAlignment {
  Left(0),
  Center,
  Right;

  public final int swigValue() {
    return swigValue;
  }

  public static HorizontalAlignment swigToEnum(int swigValue) {
    HorizontalAlignment[] swigValues = HorizontalAlignment.class.getEnumConstants();
    if (swigValue < swigValues.length && swigValue >= 0 && swigValues[swigValue].swigValue == swigValue)
      return swigValues[swigValue];
    for (HorizontalAlignment swigEnum : swigValues)
      if (swigEnum.swigValue == swigValue)
        return swigEnum;
    throw new IllegalArgumentException("No enum " + HorizontalAlignment.class + " with value " + swigValue);
  }

  @SuppressWarnings("unused")
  private HorizontalAlignment() {
    this.swigValue = SwigNext.next++;
  }

  @SuppressWarnings("unused")
  private HorizontalAlignment(int swigValue) {
    this.swigValue = swigValue;
    SwigNext.next = swigValue+1;
  }

  @SuppressWarnings("unused")
  private HorizontalAlignment(HorizontalAlignment swigEnum) {
    this.swigValue = swigEnum.swigValue;
    SwigNext.next = this.swigValue+1;
  }

  private final int swigValue;

  private static class SwigNext {
    private static int next = 0;
  }
}

