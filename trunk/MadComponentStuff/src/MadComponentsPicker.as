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
package
{
	import com.danielfreeman.madcomponents.*;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	
	public class MadComponentsPicker extends Sprite {
		
		protected static const DATA:XML = <data>
	    									<Red/>
	        								<Orange/>
	        								<Yellow/>
	        								<Green/>
	        								<Blue/>
											<Indigo/>
										 </data>;
		
		protected static const PICKER_EXAMPLE:XML = <columns gapH="0" widths="40,50%,50%" pickerHeight="180">
															<picker alignH="centre">
																<data>
																	<item label="0"/>
																	<item label="1"/>
																	<item label="2"/>
																	<item label="3"/>
																	<item label="4"/>
																	<item label="5"/>
																	<item label="6"/>
																	<item label="7"/>
																	<item label="8"/>
																	<item label="9"/>
																</data>
															</picker>
															<picker index="1">
																{DATA}
															</picker>
															<picker index="4">
																{DATA}
															</picker>
														</columns>;
		
		
		public function MadComponentsPicker(screen:Sprite = null) {
			if (screen)
				screen.addChild(this);

			stage.align = StageAlign.TOP_LEFT;  
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			UI.create(this, PICKER_EXAMPLE);
		}
	}
}