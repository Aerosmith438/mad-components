/**
 * <p>Original Author: Daniel Freeman</p>
 *
 * <p>Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:</p>
 *
 * <p>The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.</p>
 *
 * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.</p>
 *
 * <p>Licensed under The MIT License</p>
 * <p>Redistributions of files must retain the above copyright notice.</p>
 */
 
 
 package com.powerflasher.SampleApp {
	
	import flash.utils.getQualifiedClassName;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;	
	import com.danielfreeman.madcomponents.*;
	import com.danielfreeman.extendedMadness.*;
	import com.danielfreeman.stage3Dacceleration.*;
	import flash.display.Bitmap;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * @author danielfreeman
	 */
	public class WheelMenuTest1 extends Sprite {
			
			
		protected static const MONTHS:XML =
			
			<data>
				<January/>
				<February/>
				<March/>
				<April/>
				<May/>
				<June/>
				<July/>
				<August/>
				<September/>
				<October/>
				<November/>
				<December/>
			</data>;
			
		
		protected static const LAYOUT:XML =
		
			<vertical stageColour="#333333" >
				<wheelMenu id="@menu" motionBlur="true" orientation="right" radialText="true"
				alignV="centre" alignH="centre"
				rim="5" radius="130"
				background="#222222,#996633,#663300,#FF9900"
				textColour="#FF9999">
					{MONTHS}
				</wheelMenu>
			</vertical>;
			
			
		protected var _wheelMenu:WheelMenu;
		

		public function WheelMenuTest1(screen:Sprite = null) {
			if (screen)
				screen.addChild(this);

			stage.align = StageAlign.TOP_LEFT;  
			stage.scaleMode = StageScaleMode.NO_SCALE;

			WheelMenu.create(this, LAYOUT);
		}

	}
}
