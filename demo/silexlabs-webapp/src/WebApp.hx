/*
 * Cocktail, HTML rendering engine
 * http://haxe.org/com/libs/cocktail
 *
 * Copyright (c) Silex Labs
 * Cocktail is available under the MIT license
 * http://www.silexlabs.org/labs/cocktail-licensing/
*/

package;

/**
 * Class for building an web application
 * 
 * @author	Raphael Harmel
 * @date	2001-12-16
 */

 import js.Lib;
 import js.Dom;

// list specific
import components.lists.ListBase;
import components.lists.ListBaseModels;
import components.lists.ListBaseUtils;

// Utils
import Utils;



class WebApp 
{
	
	// the main container which will be attached to the body of the publication
	private var _body:Body;
	private var _mainContainer:HtmlDom;
	
	public static function main()
	{
		new WebApp();
	}
	
	/**
	 * Contructor
	 */
	public function new()
	{
		_body = Lib.document.body;
		WebAppStyle.getBodyStyle(_body);
		drawInterface();
	}
	
	/**
	 * Draws the main interface
	 */
	public function drawInterface()
	{
		// create pages
		var applicationStructure:ApplicationStructure = new ApplicationStructure();
		
		// initialize container
		_mainContainer = applicationStructure.pagesContainer;
		//WebAppStyle.getDefaultStyle(_mainContainer);
		WebAppStyle.getMainContainerStyle(_mainContainer);
		
		// attach main container to document root
		_body.appendChild(_mainContainer);

		//_body.onKeyDown = onKeyDownBody;
		//_body.onKeyDown = _mainContainer.children[0].child.children[1].onListKeyDown;
		
	}
	
	/*private function onKeyDownBody(key:KeyEventData):Void
	{
		trace("onKeyDownBody: " + key.value);
		//trace(key.value);
		if (key.value == KeyboardKeyValue.right || key.value == KeyboardKeyValue.VK_RIGHT || key.value == KeyboardKeyValue.left || key.value == KeyboardKeyValue.VK_LEFT)
		{
			// dispatch menu list item change
			_mainContainer.children[0].child.children[1].onListKeyDown(key);
		}
	}*/

}