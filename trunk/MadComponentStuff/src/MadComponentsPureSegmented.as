package
{
	import com.danielfreeman.extendedMadness.*;
	import com.danielfreeman.madcomponents.*;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	public class MadComponentsPureSegmented extends Sprite
	{
		protected static const DATA:XML = <data>
											<Apple/>
											<Orange/>
											<Banana/>
											<Pineapple/>
											<Lemon/>
										</data>;

		public function MadComponentsPureSegmented(screen:Sprite = null) {
			if (screen)
				screen.addChild(this);
			
			stage.align = StageAlign.TOP_LEFT;  
			stage.scaleMode = StageScaleMode.NO_SCALE;
			var attributes:Attributes = new Attributes(0,0,250,50);
			attributes.parse(<style background="#EEDDCC,#AA9933"/>);
			var segmentedControl:UISegmentedControl = new UISegmentedControl(this, DATA, attributes);
		}
	}
}