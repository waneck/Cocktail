/*
	This file is part of Cocktail http://www.silexlabs.org/groups/labs/cocktail/
	This project is © 2010-2011 Silex Labs and is released under the GPL License:
	This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package cocktail.core.layout;

import cocktail.core.dom.Node;
import cocktail.core.geom.GeomData;
import cocktail.core.geom.Matrix;
import cocktail.core.css.CoreStyle;
import cocktail.core.layout.formatter.FormattingContext;
import cocktail.core.renderer.ElementRenderer;
import cocktail.core.renderer.InlineBoxRenderer;
import cocktail.core.renderer.TextRenderer;
import cocktail.core.renderer.RendererData;
import cocktail.core.css.CSSData;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// Structures
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Represents the width, height of an htmlElement's
	 * parent content.
	 * Specify for each dimension if it is 'cssAuto', 
	 * meaning it depends on its content dimension
	 */
	class ContainingBlockVO {
		public var width:Float;
		public var isWidthAuto:Bool;
		public var height:Float;
		public var isHeightAuto:Bool;
		
		public function new(width:Float, isWidthAuto:Bool, height:Float, isHeightAuto:Bool)
		{
			this.width = width;
			this.isWidthAuto = isWidthAuto;
			this.height = height;
			this.isHeightAuto = isHeightAuto;
		}
	}
	
	/**
	 * Store the computed background style
	 * for one background image
	 */
	typedef ComputedBackgroundStyleData = {
		
		/**
		 * The size of the background image, it might
		 * be tiled based on the background repeat
		 * style
		 */
		var backgroundSize:DimensionVO;
		
		/**
		 * a rectangle used as origin to position
		 * the background image and might also
		 * be used to clip it based on the
		 * background clip style
		 */
		var backgroundOrigin:RectangleVO;
		
		/**
		 * The rectangle clipping the background
		 * image, might be the rectangle of the content,
		 * padding or border box of the htmlElement
		 */
		var backgroundClip:RectangleVO;
		
		/**
		 * the point of origin of the background image
		 * relative to the backgroundOrigin rectangle
		 */
		var backgroundPosition:PointVO;
		
		/**
		 * how to repeat the background image in the
		 * x and y directions
		 */
		var backgroundRepeat:CSSPropertyValue;
		
		/**
		 * the data of the background image (url or
		 * gradient data)
		 */
		var backgroundImage:CSSPropertyValue;
	}
	
	
	/**
	 * Represents the left and right
	 * floats registered for a 
	 * formatting context
	 */
	class FloatsVO {
		
		public var left:Array<RectangleVO>;
		public var right:Array<RectangleVO>;
		
		public function new(left:Array<RectangleVO>, right:Array<RectangleVO>)
		{
			this.left = left;
			this.right = right;
		}
	}
	
	class FloatVO {
		
		public var node(default, null):ElementRenderer;
		public var bounds(default, null):RectangleVO;
		
		public function new(node:ElementRenderer, bounds:RectangleVO)
		{
			this.node = node;
			this.bounds = bounds;
		}

	}

	
	