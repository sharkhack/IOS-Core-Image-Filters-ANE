package com.azer.iosfilters
{
	import flash.display.BitmapData;
	import flash.external.ExtensionContext;
	
	public class IOSFilters
	{
		private static var _instance : IOSFilters;
		private static var ext:ExtensionContext = null;
		
		public function IOSFilters()
		{
			if (!_instance)
			{
				if(ext == null){
					ext = ExtensionContext.createExtensionContext("com.azer.iosfilters",null);
					
				}
				_instance = this;
			}
		}
		
		public static function getInstance() : IOSFilters
		{
			return _instance ? _instance : new IOSFilters();
		}
		
		public function CreateSigContext():void
		{
			ext.call( "CreateSigContext");
		}
		
		/**
		 * ios Core Image Filter
		 * 
		 * @param inputImage for A CIImage object whose display name is Image. 
		 * @param filterName (String) is Core Image Filters Name Example = CIBoxBlur
		 * @param keys (String array) are the image filters parameter names for example ; [inputRadius]
		 * @param vals (Number array) is the image filters parameters for example (keys value);  [10.00] ---> CIBoxBlur Default value: 10.00
		 */
		public function CoreImageFilterRequest(inputImage:BitmapData,filterName:String='CIVibrance', keys:Array = null, vals:Array = null):void
		{
			if(keys!=null)
			{
				ext.call( "CoreImageFilterRequest",inputImage,filterName,keys, vals);
			}
			else
			{
				ext.call( "CoreImageFilterRequest",inputImage,filterName);
			}
		}
		
		
	}
}