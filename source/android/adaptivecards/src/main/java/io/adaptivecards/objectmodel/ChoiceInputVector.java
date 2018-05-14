/* ----------------------------------------------------------------------------
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.9
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
 * ----------------------------------------------------------------------------- */

package io.adaptivecards.objectmodel;

public class ChoiceInputVector {
  private transient long swigCPtr;
  protected transient boolean swigCMemOwn;

  protected ChoiceInputVector(long cPtr, boolean cMemoryOwn) {
    swigCMemOwn = cMemoryOwn;
    swigCPtr = cPtr;
  }

  protected static long getCPtr(ChoiceInputVector obj) {
    return (obj == null) ? 0 : obj.swigCPtr;
  }

  protected void finalize() {
    delete();
  }

  public synchronized void delete() {
    if (swigCPtr != 0) {
      if (swigCMemOwn) {
        swigCMemOwn = false;
        AdaptiveCardObjectModelJNI.delete_ChoiceInputVector(swigCPtr);
      }
      swigCPtr = 0;
    }
  }

  public ChoiceInputVector() {
    this(AdaptiveCardObjectModelJNI.new_ChoiceInputVector__SWIG_0(), true);
  }

  public ChoiceInputVector(long n) {
    this(AdaptiveCardObjectModelJNI.new_ChoiceInputVector__SWIG_1(n), true);
  }

  public long size() {
    return AdaptiveCardObjectModelJNI.ChoiceInputVector_size(swigCPtr, this);
  }

  public long capacity() {
    return AdaptiveCardObjectModelJNI.ChoiceInputVector_capacity(swigCPtr, this);
  }

  public void reserve(long n) {
    AdaptiveCardObjectModelJNI.ChoiceInputVector_reserve(swigCPtr, this, n);
  }

  public boolean isEmpty() {
    return AdaptiveCardObjectModelJNI.ChoiceInputVector_isEmpty(swigCPtr, this);
  }

  public void clear() {
    AdaptiveCardObjectModelJNI.ChoiceInputVector_clear(swigCPtr, this);
  }

  public void add(ChoiceInput x) {
    AdaptiveCardObjectModelJNI.ChoiceInputVector_add(swigCPtr, this, ChoiceInput.getCPtr(x), x);
  }

  public ChoiceInput get(int i) {
    long cPtr = AdaptiveCardObjectModelJNI.ChoiceInputVector_get(swigCPtr, this, i);
    return (cPtr == 0) ? null : new ChoiceInput(cPtr, true);
  }

  public void set(int i, ChoiceInput val) {
    AdaptiveCardObjectModelJNI.ChoiceInputVector_set(swigCPtr, this, i, ChoiceInput.getCPtr(val), val);
  }

}
