/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/
package cocktail.core.window;

import cocktail.core.dom.Document;
import cocktail.core.event.Event;
import cocktail.core.event.EventCallback;
import cocktail.core.event.UIEvent;
import cocktail.core.html.HTMLAnchorElement;
import cocktail.core.html.HTMLConstants;
import cocktail.core.html.HTMLDocument;
import cocktail.port.NativeBitmapData;
import cocktail.port.platform.Platform;
import cocktail.core.css.CSSData;
import cocktail.core.layout.LayoutData;
import cocktail.core.history.History;

/**
 * Represents the window through which the Document is
 * viewed
 * 
 * It holds a reference to the class proxying access
 * to platform specific event and methods
 * 
 * TODO 3 : should implement onload callback
 * 
 * TODO 2 : should Platform be owned by Window ? Document ?
 * or by another DOMImplementation class ?
 * 
 * @author Yannick DOMINGUEZ
 */
class Window extends EventCallback
{
	/**
	 * return the document viewed through the window
	 */
	public var document(default, null):HTMLDocument;
	
	/**
	 * Height (in pixels) of the browser window viewport including,
	 * if rendered, the horizontal scrollbar.
	 */
	public var innerHeight(get_innerHeight, never):Int;
	
	/**
	 * Width (in pixels) of the browser window viewport including,
	 * if rendered, the vertical scrollbar.
	 */
	public var innerWidth(get_innerWidth, never):Int;
	
	/**
	 * A reference to the class through which platform specific
	 * events and methods are retrieved
	 */
	public var platform(default, null):Platform;
	
	/**
	 * A reference to the history instance
	 */
	public var history:History;
	
	/**
	 * Store the current mouse cursor value
	 * to ensure that it needs changing
	 */
	private var _currentMouseCursor:CSSPropertyValue;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// CONSTRUCTOR & INIT
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * class constructor. Initialise the Document
	 */
	public function new() 
	{
		super();
		init();
	}
	
	/**
	 * Initialise the Document and set platform specific
	 * listener on it
	 */
	private function init():Void
	{
		platform = new Platform();
		var htmlDocument:HTMLDocument = new HTMLDocument(this);
		
		platform.mouse.onMouseDown = htmlDocument.onPlatformMouseEvent;
		platform.mouse.onMouseUp = htmlDocument.onPlatformMouseEvent;
		platform.mouse.onMouseMove = htmlDocument.onPlatformMouseMoveEvent;
		platform.mouse.onMouseWheel = htmlDocument.onPlatformMouseWheelEvent;
		
		platform.keyboard.onKeyDown = htmlDocument.onPlatformKeyDownEvent;
		platform.keyboard.onKeyUp = htmlDocument.onPlatformKeyUpEvent;
		
		platform.nativeWindow.onResize = onPlatformResizeEvent;
		
		platform.touchListener.onTouchStart = htmlDocument.onPlatformTouchEvent;
		platform.touchListener.onTouchMove = htmlDocument.onPlatformTouchEvent;
		platform.touchListener.onTouchEnd = htmlDocument.onPlatformTouchEvent;
		
		//fullscreen callbacks
		htmlDocument.onEnterFullscreen = onDocumentEnterFullscreen;
		htmlDocument.onExitFullscreen = onDocumentExitFullscreen;
		platform.nativeWindow.onFullScreenChange = onPlatformFullScreenChange;
		
		//mouse cursor callback
		htmlDocument.onSetMouseCursor = onDocumentSetMouseCursor;
		
		document = htmlDocument;

		// history
		history = new History();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PUBLIC METHOD
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Creates a new secondary browser window and loads the referenced resource.
	 */
	public function open(url:String, name:String = HTMLConstants.TARGET_BLANK):Void
	{
		platform.nativeWindow.open(url, name);
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// FULLSCREEN CALLBACKS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Called when the user exits or enter fullscreen mode without using
	 * the DOM api. For instance, in most browser, pressing the escape key
	 * will exit fullscreen mode.
	 * 
	 * Listening to those platform event allows to keep the DOM model
	 * in sync
	 */
	private function onPlatformFullScreenChange(event:Event):Void
	{
		//if the platform just exited the fullscreen mode,
		//then the document must also exit it
		if (platform.nativeWindow.fullscreen() == false)
		{
			document.exitFullscreen();
		}
	}
	
	/**
	 * Called when the document request to enter fullscreen mode.
	 * Start fullscreen mode using platform specific API
	 */
	private function onDocumentEnterFullscreen():Void
	{
		platform.nativeWindow.enterFullscreen();
	}
		
	/**
	 * Called when the document request to exit fullscreen mode.
	 * Exit fullscreen mode using platform specific API
	 */
	private function onDocumentExitFullscreen():Void
	{
		platform.nativeWindow.exitFullscreen();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// MOUSE CURSOR CALLBACKS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Change the current mouse cursor if needed
	 */
	private function onDocumentSetMouseCursor(cursor:CSSPropertyValue):Void
	{
		//null when first called
		if (_currentMouseCursor == null)
		{
			_currentMouseCursor = cursor;
			platform.mouse.setMouseCursor(cursor);
		}
		else
		{
			//only update mouse if the value is different
			//from the current one
			if (cursor != _currentMouseCursor)
			{
				_currentMouseCursor = cursor;
				platform.mouse.setMouseCursor(cursor);
			}
		}
		
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PRIVATE METHODS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * When the viewport is resized, invalidate
	 * the html document so that its layout
	 * and rendering gets updated
	 */
	private function onPlatformResizeEvent(e:UIEvent):Void
	{
		document.invalidationManager.invalidateViewportSize();
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// SETTERS/GETTERS
	//////////////////////////////////////////////////////////////////////////////////////////
	
	private function get_innerHeight():Int
	{
		return platform.nativeWindow.innerHeight;
	}
	
	private function get_innerWidth():Int
	{
		return platform.nativeWindow.innerWidth;
	}
}