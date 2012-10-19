﻿/** * <p>Original Author: Daniel Freeman</p> * * <p>Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions:</p> * * <p>The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software.</p> * * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE.</p> * * <p>Licensed under The MIT License</p> * <p>Redistributions of files must retain the above copyright notice.</p> */package com.danielfreeman.madcomponents {	import flash.display.DisplayObject;	import flash.display.Shape;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.geom.Point;	import flash.utils.Timer;	import flash.geom.Rectangle;/** * Scrolling has started */	[Event( name="scrollStarted", type="flash.events.Event" )]	/** * Scrolling has ceased */	[Event( name="scrollStopped", type="flash.events.Event" )]		/** * Scrolling has moved */	[Event( name="scrollMoved", type="flash.events.Event" )]	  /** *  MadComponents vertically scrolling container * <pre> * &lt;scrollVertical *    id = "IDENTIFIER" *    colour = "#rrggbb" *    background = "#rrggbb, #rrggbb, …" *    gapV = "NUMBER" *    gapH = "NUMBER" *    alignH = "left|right|centre|fill" *    alignV = "top|bottom|centre|fill" *    visible = "true|false" *    border = "true|false" *    autoLayout = "true|false" *    alignV = "scroll|no scroll" * /&gt; * </pre> */		public class UIScrollVertical extends MadMasking implements IContainerUI {		public static const STARTED:String = "scrollStarted";		public static const STOPPED:String = "scrollStopped";		public static const MOVED:String = "scrollMoved";		protected static const DELTA_THRESHOLD:Number = 2.0;		protected static const THRESHOLD:Number = 6.0;		protected static const PADDING:Number = 10.0;				protected static const SCROLLBAR_POSITION:Number = 2.0;		protected static const SCROLLBAR_WIDTH:Number = 5.0;		protected static const MAXIMUM_DY:Number = 2048.0;		protected static const FINISHED:Number = -99999;				protected static const MARGIN:Number = 6.0;				public static var DECAY:Number = 0.95;		public static var DELTA:int = 16;		public static var DELTA_TOUCH:int = 16;		public static var BOUNCE:Number = 0.5;		public static var CLICK_DURATION:int = 167;		protected var _maximumSlide:Number;		protected var _delta:Number = 0.0;		protected var _startMouse:Point = new Point();		protected var _startSlider:Point = new Point();		protected var _endSlider:Number = -1;		protected var _slider:Sprite;		protected var _sliderPosition:Number = 0;				protected var _touchTimer:Timer = new Timer(DELTA_TOUCH);		protected var _moveTimer:Timer = new Timer(DELTA);		protected var _dragTimer:Timer = new Timer(DELTA);		protected var _clickTimer:Timer = new Timer(CLICK_DURATION,1);		protected var _distance:Number = 0;		protected var _pressButton:DisplayObject;		protected var _scrollBarLayer:Shape;		protected var _width:Number;		protected var _height:Number;		protected var _colour:uint;		protected var _scrollBarColour:uint;		protected var _noScroll:Boolean;		protected var _deltaThreshold:Number = 1.0;		protected var _listClickable:Boolean = true;		protected var _autoLayout:Boolean = false;		protected var _decay:Number = DECAY;		protected var _offset:Number = 0;		protected var _scrollBarVisible:Boolean = false;		protected var _scrollerWidth:Number = -1;		protected var _scrollerHeight:Number = -1;		protected var _border:String;		protected var _scale:Number = 1.0;					public function UIScrollVertical(screen:Sprite, xml:XML, attributes:Attributes) {			if (screen) {				screen.addChildAt(this,0);			}			super(xml, attributes);						_border = xml.@border.length()>0 ? xml.@border[0] : "";			_colour = attributes.colour;			_noScroll = attributes.noScroll;			_scrollBarColour = attributes.scrollBarColour;			createSlider(xml, attributes);			if (xml.@autoLayout.length()>0 && xml.@autoLayout[0]!="false") {				_slider.addEventListener(UIImageLoader.LOADED, doLayoutHandler);				_autoLayout = true;			}			addChild(_scrollBarLayer = new Shape());			_scrollBarLayer.alpha = 0.8;			_clickTimer.addEventListener(TimerEvent.TIMER, clickUp);			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);			addListeners();			drawComponent();			androidMouseDisable(_slider);					//	if (xml.@mask.length()>0 && xml.@mask[0]!="false")		//		scrollRect = new Rectangle(0,0,attributes.widthH,attributes.heightV);					startMasking();		}						protected function addListeners():void {			_touchTimer.addEventListener(TimerEvent.TIMER, mouseMove);			_dragTimer.addEventListener(TimerEvent.TIMER, mouseDrag);			_moveTimer.addEventListener(TimerEvent.TIMER, movement);		//	_clickTimer.addEventListener(TimerEvent.TIMER, clickUp);		}						protected function removeListeners():void {			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);			_touchTimer.removeEventListener(TimerEvent.TIMER, mouseMove);			_dragTimer.removeEventListener(TimerEvent.TIMER, mouseDrag);			_moveTimer.removeEventListener(TimerEvent.TIMER, movement);		//	_clickTimer.removeEventListener(TimerEvent.TIMER, clickUp);		}		/** *  If false, scrolling is locked. */		public function set scrollEnabled(value:Boolean):void {			_noScroll = !value;			if (_noScroll)				stopMovement();		}		/** *  Is this container scrollable, or locked? */		public function get scrollEnabled():Boolean {			return !_noScroll;		}		/** *  Draw background */			public function drawComponent():void {			UI.drawBackgroundColour(_attributes.backgroundColours, _width, _height, this);		}		/** *  Returns scrolling form within array */			public function get pages():Array {			return [_slider];		}						public function get attributes():Attributes {			return _attributes;		}						public function get xml():XML {			return _xml;		}		/** *  Rearrange the layout to new screen dimensions */			public function layout(attributes:Attributes):void {			_attributes = attributes;			if (_slider is IContainerUI) {				IContainerUI(_slider).layout(sliderAttributes(attributes));			}			drawComponent();			adjustMaximumSlide();					//	if (scrollRect)		//		scrollRect = new Rectangle(0,0,attributes.width,attributes.height);					refreshMasking();		}						public function rowRectangle(y:Number):Rectangle {			for (var l:int=0;l<_slider.numChildren - 1;l++) {				var row:DisplayObject = _slider.getChildAt(l+1);				if (row.y + row.height + _attributes.paddingV > y) {					return new Rectangle(row.x - _attributes.paddingH / 2, row.y - _attributes.paddingV / 2, row.width + _attributes.paddingH, row.height + _attributes.paddingV);				}			}			return null;		}		/** *  Update maximum slide */			protected function adjustMaximumSlide():void {			var sliderHeight:Number = _scrollerHeight>0 ? _scrollerHeight*_scale : _slider.height;			_maximumSlide = sliderHeight - _height + PADDING * (_border=="false" ? 0 : 1);			if (_maximumSlide < 0)				_maximumSlide = 0;			if (sliderY < -_maximumSlide)				sliderY = -_maximumSlide;		}						protected function doLayoutHandler(event:Event):void {			doLayout();			event.stopPropagation();		}						public function get maximumSlide():Number {			return _maximumSlide;		}		/** *  Refresh */			public function doLayout():void {			if (_slider is UIForm) {				if (_autoLayout)					UIForm(_slider).doLayout();				adjustMaximumSlide();			}		}		/** *  Create sliding part of container */			protected function createSlider(xml:XML, attributes:Attributes):void {			_slider = new UI.FormClass(this, xml, sliderAttributes(attributes));			_slider.name = "-";			adjustMaximumSlide();		}						protected function sliderAttributes(attributes:Attributes):Attributes {			_width = attributes.width;			_height = attributes.height;			var newAttributes:Attributes = attributes.copy();			var padding:Number = (_border=="true" || (_border!="false" && _xml.localName().toString().indexOf("scroll")>=0)) ? PADDING : 0;			if (_xml.@width.length()>0) {				newAttributes.width = _scrollerWidth = parseFloat(_xml.@width[0]);			}			if (_xml.@height.length()>0) {				newAttributes.height = _scrollerHeight = parseFloat(_xml.@height[0]);			}			newAttributes.width -= 2*padding;			newAttributes.x=padding;			newAttributes.y=padding;			return newAttributes;		}		/** *  Disable touch events to scrolling components */			protected function androidMouseDisable(item:Sprite):void {			for (var i:int = 0; i<item.numChildren;i++) {				var child:DisplayObject = DisplayObject(item.getChildAt(i));				if (child is IContainerUI && Sprite(child).mouseChildren) {					for each (var page:Sprite in IContainerUI(child).pages) {						androidMouseDisable(page);					}					if (child is UIForm) {						UIForm(child).insideScroller();					}				}				else if (!(child is UIInput) && !(child is UISearch) && child.hasOwnProperty("mouseEnabled")) {					Object(child).mouseEnabled = false;				}			} 		}						protected function mouseDown(event:MouseEvent):void {			if (_pressButton)				return;		//	hideScrollBar();			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);			_startMouse.x = mouseX;			_startMouse.y = mouseY;			_startSlider.x = _slider.x;			_startSlider.y = sliderY;			_listClickable = !_moveTimer.running;		//	_moveTimer.stop();			_touchTimer.reset();			_touchTimer.start();			_distance = 0;		}						protected function mouseUp(event:MouseEvent):void {			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);			_dragTimer.stop();			_touchTimer.stop();			if (!_noScroll) {				startMovement();			}			if (_pressButton) {				_pressButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));				stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));				_pressButton = null;			}			else if (_distance < THRESHOLD && _listClickable && pressButton()) {			//	_clickTimer.reset();			//	_clickTimer.start();				_clickTimer.stop();				clickUp(new TimerEvent(TimerEvent.TIMER));				stopMovement(); //new			}			_scrollBarLayer.graphics.clear();		}				protected function mouseMove(event:TimerEvent):void {			var newSliderY:Number;			if (!_noScroll) {				_delta = -sliderY;				newSliderY = _startSlider.y + (mouseY - _startMouse.y);				_delta += newSliderY;				_distance += Math.abs(_delta)+Math.abs(mouseX - _startMouse.x);						sliderY = newSliderY;				if (Math.abs(_delta) > DELTA_THRESHOLD || _distance > THRESHOLD) {				//	sliderY = newSliderY;					showScrollBar();				}			}		}						protected function mouseDrag(event:TimerEvent):void {			if (_pressButton) {				_pressButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));			}		}		/** *  Start scrolling movement */			protected function startMovement():void {			_endSlider = FINISHED-1;			startMovement0();			_moveTimer.start();		}						protected function startMovement0():Boolean {			if (sliderY > _offset) {				_endSlider = -_offset;				return true;			}			else if (sliderY < -_maximumSlide ) {				_endSlider = _maximumSlide;				return true;			}			return false;		}		/** *  Animate scrolling movement */		protected function movement(event:TimerEvent):void {			if (_endSlider<FINISHED) {				_delta *= _decay;				sliderY = sliderY + _delta;			//	if (_distance > THRESHOLD) {					showScrollBar();			//	}				if (Math.abs(_delta) < _deltaThreshold || sliderY > 0 || sliderY < -_maximumSlide) {					if (!startMovement0())						stopMovement();				}			}			else {				_delta = (-_endSlider - sliderY) * BOUNCE;				sliderY = sliderY + _delta;				showScrollBar();				if (Math.abs(_delta) < _deltaThreshold) {					sliderY = -_endSlider;					stopMovement();				}			}		}		/** *  Stop scrolling movement */		protected function stopMovement():void {			_delta = 0;			_moveTimer.stop();			hideScrollBar();		}		/** *  Show scroll bar */		public function showScrollBar():void {			if (!_scrollBarVisible) {				_scrollBarVisible = true;				_slider.cacheAsBitmap = true;				dispatchEvent(new Event(STARTED));			}			drawScrollBar();		}		/** *  Draw scroll bar */		protected function drawScrollBar():void {			var sliderHeight:Number = _scrollerHeight>0 ? _scrollerHeight*_scale : _slider.height;			_scrollBarLayer.graphics.clear();			var barHeight:Number = (_height / sliderHeight) * _height;			var barPosition:Number = (- sliderY / sliderHeight) * _height + 2*SCROLLBAR_POSITION;			if (barPosition < SCROLLBAR_POSITION) {				barHeight += barPosition;				barPosition = SCROLLBAR_POSITION;				}			if (barPosition + barHeight > _height - 4 * SCROLLBAR_POSITION) {				barHeight -= barPosition + barHeight - _height + 4 * SCROLLBAR_POSITION;			}			if (barHeight > 0 && barPosition >= 0) {				_scrollBarLayer.graphics.beginFill(_scrollBarColour);				_scrollBarLayer.graphics.drawRoundRect(_width - SCROLLBAR_WIDTH - SCROLLBAR_POSITION, barPosition, SCROLLBAR_WIDTH, barHeight, SCROLLBAR_WIDTH);			}		}/** *  Hide scroll bar */		public function hideScrollBar():void {			dispatchEvent(new Event(STOPPED));			if (_scrollBarVisible) {				_scrollBarLayer.graphics.clear();				_scrollBarVisible = false;				_slider.cacheAsBitmap = false;			}		}/** *  Determine what has been clicked */		protected function doSearchHit():void {			if (!_pressButton) {				_pressButton = searchHit(_slider);				if (_pressButton is UIInput) {					_pressButton = null;				}				else if (_pressButton ) {					_pressButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));				}			}		}				protected function pressButton():DisplayObject {			doSearchHit();			return _pressButton;		}		/** *  Touch up handler */		protected function clickUp(event:TimerEvent):void {			if (_pressButton && _distance < THRESHOLD) {				_pressButton.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));				_pressButton = null;				stopMovement();			}		}		/** *  Return DisplayObject of what has been clicked */		public static function searchHit(container:Sprite = null):DisplayObject {		var found:DisplayObject = null;			for (var i:int = 0; i < container.numChildren && !found; i++) {				var item:* = container.getChildAt(container.numChildren - i -1);				if (item is UIForm && UIForm(item).mouseEnabled) {					found = searchHit(item);				}				else {					if (item && inBounds(item, container.mouseX, container.mouseY) && !(item is UILabel) && !((item is MadSprite) && !MadSprite(item).clickable)) {						found = item;					}				}			}			return found;		}				/** *  Return DisplayObject of what has been clicked */		public static function searchHitChild(item:DisplayObject = null):DisplayObject {			var found:DisplayObject = null;			if (item is Sprite && Sprite(item).mouseEnabled) {				for (var i:int = 0; i < Sprite(item).numChildren && !found; i++) {					found = searchHitChild(Sprite(item).getChildAt(Sprite(item).numChildren - i -1));				}			}			var bounds:Rectangle = item.getBounds(item);			if (!found && inBoundsChild(item, item.mouseX-bounds.x, item.mouseY-bounds.y) && !((item is Sprite) && !Sprite(item).mouseEnabled)) {				found = item;			}			return found;		}		/** *  Is the touch in bounds of a particular component? */		protected static function inBounds(item:DisplayObject, x:Number, y:Number):Boolean {			return x > item.x-MARGIN && y > item.y-MARGIN && x < item.x + item.width + MARGIN && y < item.y + item.height + MARGIN;		}		/** *  Is the touch in bounds of a particular component? */		protected static function inBoundsChild(item:DisplayObject, x:Number, y:Number):Boolean {			return x > -MARGIN && y > -MARGIN && x < item.width + MARGIN && y < item.height + MARGIN;		}		/** *  Clear scrolling form */		public function clear():void {			IContainerUI(_slider).clear();		}		/** *  Search for component that matches id */		public function findViewById(id:String, row:int=-1, group:int = -1):DisplayObject {			return IContainerUI(_slider).findViewById(id, row, group);		}				public function set sliderY(value:Number):void {			if (Math.abs(value - _sliderPosition) < MAXIMUM_DY) {				_sliderPosition = value;				if (_slider.visible) {					_slider.y = _sliderPosition;				}				sliderMoved();			}		}						public function get sliderY():Number {			return _sliderPosition;		}						public function set sliderVisible(value:Boolean):void {			if (value) {				addListeners();				hideScrollBar();			}			else {				removeListeners();			}			_slider.y = _sliderPosition;			_slider.visible = value;			_moveTimer.stop();			_touchTimer.stop();					}						public function get sliderVisible():Boolean {			return _slider.visible;		}		/** *  Set vertical scroll position */		public function set scrollPositionY(value:Number):void {			_slider.y = -value;			if (value > _maximumSlide) {				_slider.y = -_maximumSlide;			}			sliderMoved();		}						protected function sliderMoved():void {		//	dispatchEvent(new Event(MOVED));		}						public function get scrollPositionY():Number {			return -sliderY;		}		/** *  Set array of objects data */		public function set data(values:Object):void {			if (_slider is UIForm) {				UIForm(_slider).data = values;				if (_autoLayout)					UIForm(_slider).doLayout();				adjustMaximumSlide();			}		}		/** *  Model */		public function get model():Model {			return (_slider is UIForm) ? UIForm(_slider).model : null;		}						public function destructor():void {			removeListeners();			_slider.removeEventListener(UIImageLoader.LOADED, doLayoutHandler);			_touchTimer.stop();			_moveTimer.stop();			_dragTimer.stop();			_clickTimer.stop();			UI.clear(_slider);		}	}}