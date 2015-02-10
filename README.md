Air Native Extension For IOS Core Image Filters
===============

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for using IOS Core Image Filters on IOS. It has been developed by [Azer BULBUL](https://github.com/sharkhack).

This AIR Native Extension exposes IOS Core Image Filters to Adobe AIR.

- The ANE binary (IOSPhotoFilters.ane) is located in the */AS3/IOSPhotoFilters/release* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).


- This ANE included [ios core imagage framework](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/uid/TP40004346)

- You can also find out about the built-in filters on a system by using the Core Image API. See [Core Image Programming Guide](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_intro/ci_intro.html#//apple_ref/doc/uid/TP30001185)

USAGE

```actionscript

  var mc:MovieClip = new MovieClip();
  var originalImage:bitmapData = [set the any image bitmapdata referance];
  var displayBitmap:Bitmap = new Bitmap(originalImage.clone());
  mc.addChild(displayBitmap);


  var inputImage:BitmapData = displayBitmap.bitmapData;

  IOSFilters.getInstance().CreateSigContext();
  IOSFilters.getInstance().CoreImageFilterRequest(inputImage,"CISepiaTone",['inputIntensity'],[1.00]);

  displayBitmap.bitmapData = inputImage;
```

Authors
------

This ANE has been written by [Azer BULBUL](https://github.com/sharkhack) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

