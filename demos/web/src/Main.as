package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.system.Capabilities;
	
	import starling.core.Starling;
	
	[SWF(width="800",height="600",backgroundColor="#000000",frameRate="60")]
	public class Main extends Sprite
	{
		private var starling:Starling;
		
		public function Main()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(event:Event = null):void
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			starling = new Starling(BasicLightingExample, stage, null, null, Context3DRenderMode.AUTO, "baseline" /*Context3DProfile.BASELINE*/);
			starling.simulateMultitouch = false;
			starling.enableErrorChecking = Capabilities.isDebugger;
			starling.antiAliasing = 0;			
			starling.start();
		}
	}
}
