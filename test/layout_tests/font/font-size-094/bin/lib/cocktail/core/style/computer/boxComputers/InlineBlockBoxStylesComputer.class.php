<?php

class cocktail_core_style_computer_boxComputers_InlineBlockBoxStylesComputer extends cocktail_core_style_computer_boxComputers_BoxStylesComputer {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public function getComputedAutoMargin($marginStyleValue, $opositeMargin, $containingHTMLElementDimension, $computedDimension, $isDimensionAuto, $computedPaddingsDimension, $fontSize, $xHeight, $isHorizontalMargin) {
		return 0.0;
	}
	function __toString() { return 'cocktail.core.style.computer.boxComputers.InlineBlockBoxStylesComputer'; }
}
