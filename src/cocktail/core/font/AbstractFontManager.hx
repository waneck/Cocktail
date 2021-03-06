/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/
package cocktail.core.font;

import cocktail.core.font.FontData;
import cocktail.port.FontLoader;
import cocktail.port.NativeElement;
import cocktail.core.style.ComputedStyle;
import cocktail.core.style.StyleData;

/**
 * This class is the manager for system and embedded fonts. Use it to load new fonts, or to check if a system font is supported, etc.
 * 
 * It also is used to create native text elements using runtime specific font API's
 * 
 * It is a base class, which is extended for each target.
 * @author lexa
 */
class AbstractFontManager 
{	
	/**
	 * List of loaded fonts, successfull loaded fonts only
	 */
	private static var _loadedFonts:Array<FontData>;
	
	/**
	 * the font loaders for currently loading fonts
	 */
	private static var _fontLoaderArray:Array<FontLoader>;
	
	/**
	 * A cache of the computed font metrics where the
	 * keys are the font name and the font size
	 */
	private static var _computedFontMetrics:Hash<Hash<FontMetricsData>>;
	
	/**
	 * Constructor initializes the static attributes
	 */
	public function new()
	{
		if(_fontLoaderArray == null)
			_fontLoaderArray = new Array();
		if(_loadedFonts == null)
			_loadedFonts = new Array();
		if (_computedFontMetrics == null)
			_computedFontMetrics = new Hash();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Public virtual methods
	//////////////////////////////////////////////////////////////////////////////////////////
	/** 
	 * Returns a list of fonts which have been loaded.
	 */
	public function getEmbeddedFonts() : Array<FontData>
	{
		return _loadedFonts;
	}
	/** 
	 * Returns a list of fonts which are installed on the current runtime.
	 */
	public function getSystemFonts() : Array<FontData>
	{
		throw ("Virtual method should be implemented in sub class");
		return null;
	}
	/** 
	 * Returns true if the font specified bay fontName has been loaded or is available as a system font.
	 */
	public function hasFont(fontName:String) : Bool
	{
		var fontDataArray : Array<FontData>;
		var idx : Int;
		
		// check in the loaded fonts
		fontDataArray = getEmbeddedFonts();
		for (idx in 0...fontDataArray.length)
			if (fontDataArray[idx].name == fontName)
				return true;
		
		// check in the system fonts
		fontDataArray = getSystemFonts();
		for (idx in 0...fontDataArray.length)
			if (fontDataArray[idx].name == fontName)
				return true;
		
		return false;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Public virtual methods, font rendering and measure
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Returns metrics for a given
	 * font and font size
	 */
	public function getFontMetrics(fontFamily:String, fontSize:Float):FontMetricsData
	{
		var fontMetrics:FontMetricsData;
		
		//this method caches all the generated font metrics and
		//tries first to retrieve them on subsequent calls
		
		if (_computedFontMetrics.exists(fontFamily) == true)
		{
			var fontSizeHash:Hash<FontMetricsData> = _computedFontMetrics.get(fontFamily);
			if (fontSizeHash.exists(Std.string(fontSize)) == true)
			{
				fontMetrics = fontSizeHash.get(Std.string(fontSize));
			}
			else
			{
				fontMetrics = doGetFontMetrics(fontFamily, fontSize);
				fontSizeHash.set(Std.string(fontSize), fontMetrics);
				_computedFontMetrics.set(fontFamily, fontSizeHash); 
			}
		}
		else
		{
			fontMetrics = doGetFontMetrics(fontFamily, fontSize);
			var fontSizeHash:Hash<FontMetricsData> = new Hash<FontMetricsData>();
			fontSizeHash.set(Std.string(fontSize), fontMetrics);
			
			_computedFontMetrics.set(fontFamily, fontSizeHash); 
		}
		
		return fontMetrics;
	}
	
	/**
	 * create a runtime specific text display
	 * element for the provided text string
	 * and the styles that were computed for
	 * this text
	 */
	public function createNativeTextElement(text:String, computedStyle:ComputedStyle):NativeElement
	{
		throw ("Virtual method should be implemented in sub class");
		return null;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Private methods, font rendering and measure
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function doGetFontMetrics(fontFamily:String, fontSize:Float):FontMetricsData
	{
		throw ("Virtual method should be implemented in sub class");
		return null;
	}
	
	/**
	 * Transform a text letters into uppercase, lowercase
	 * or capitalise them (only the first letter of each word
	 * is transformed to uppercase)
	 * 
	 * TODO 3 : should be on TextRenderer instead
	 */
	private function applyTextTransform(text:String, textTransform:TextTransform):String
	{
		switch (textTransform)
		{
			case uppercase:
				text = text.toUpperCase();
				
			case lowercase:
				text = text.toLowerCase();
				
			case capitalize:
				text = capitalizeText(text);
				
			case none:
		}
		
		return text;
	}
	
	/**
	 * Capitalise a text (turn each word's first letter
	 * to uppercase)
	 * 
	 * TODO 3 : should be on TextRenderer instead
	 */
	public function capitalizeText(text:String):String
	{
		var capitalizedText:String = "";
		
		/**
		 * concatenate each character and transform
		 * the first to upper case
		 */
		for (i in 0...text.length)
		{	
			if (i == 0)
			{
				capitalizedText += text.charAt(i).toUpperCase();
			}
			else
			{
				capitalizedText += text.charAt(i);
			}
			
		}
		return capitalizedText;
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Public methods, fonts loading
	//////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Start loading a font
	 * @param	url the url of the font to load
	 * @param	name the name of the font to load. 
	 * This is an equivalent of font-family in HTML, and an equivalent of the export name in Flash. 
	 * This is the name you want to put in the css class to apply the style to some text.
	 * @param	successCallback the callback which must be called once the file is successfully done loading
	 * @param	errorCallback the callback which must be called if there was an error during loading
	 */
	public function loadFont(url : String, name : String, successCallback : FontData->Void = null, errorCallback : FontData->String->Void = null):Void
	{
		// check if the font is allready loading
		var fontLoader : FontLoader;
		var idx : Int;

		for (idx in 0..._fontLoaderArray.length)
		{
			if (_fontLoaderArray[idx].fontData.url == url && _fontLoaderArray[idx].fontData.name == name)
			{
				_fontLoaderArray[idx].addCallback(successCallback, errorCallback);
				return ;
			}
		}
		// create the font loader 
		fontLoader = new FontLoader();
		fontLoader.addCallback(_onFontLoadingSuccess, _onFontLoadingError);
		fontLoader.addCallback(successCallback, errorCallback);
		fontLoader.load(url, name);
		_fontLoaderArray.push(fontLoader);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Private methods, font loading callbacks
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * A font has been loaded
	 */
	private function _onFontLoadingSuccess(fontData : FontData)
	{
		// store the font data
		_loadedFonts.push(fontData);
		
		// free the font loader
		if (_removeFontLoader(fontData) == false)
		{
			// to do handle error
			trace("could not remove font loader from the list after the font was successfully loaded");
		}
	}
	/**
	 * A font could not be loaded
	 */
	private function _onFontLoadingError(fontData : FontData, errorStr : String)
	{
		// to do handle error
		trace("font loading has failed");
		
		// free the font loader
		if (_removeFontLoader(fontData) == false)
		{
			// to do handle error
			trace("could not remove font loader from the list after the font loading has failed");
		}
	}
	//////////////////////////////////////////////////////////////////////////////////////////
	// Private methods, utilities
	//////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Remove a font loader from the list
	 */
	private function _removeFontLoader(fontData : FontData) : Bool
	{
		// find the font loader
		var fontLoader : FontLoader;
		var idx : Int;
		for (idx in 0..._fontLoaderArray.length)
		{
			if (_fontLoaderArray[idx].fontData.url == fontData.url && _fontLoaderArray[idx].fontData.name == fontData.name)
			{
				_fontLoaderArray.remove(_fontLoaderArray[idx]);
				return true;
			}
		}
		return false;
	}
}