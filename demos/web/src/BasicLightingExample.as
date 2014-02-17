package 
{
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.extensions.lighting.core.LightBase;
	import starling.extensions.lighting.core.LightLayer;
	import starling.extensions.lighting.core.display.Polygon;
	import starling.extensions.lighting.geometry.QuadShadowGeometry;
	import starling.extensions.lighting.geometry.PolygonShadowGeometry;
	import starling.extensions.lighting.lights.DirectionalLight;
	import starling.extensions.lighting.lights.PointLight;
	import starling.extensions.lighting.lights.SpotLight;
	import starling.textures.Texture;
	import starling.animation.Transitions;
    import starling.display.BlendMode;
    import starling.display.Quad;
    import starling.text.BitmapFont;
    import starling.text.TextField;
    import starling.utils.HAlign;
    import starling.utils.VAlign;
	import starling.utils.formatString;

	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	/**
	 * @author Szenia Zadvornykh
	 */
	public class BasicLightingExample extends Sprite
	{
		private var lightLayer:LightLayer;
		private var objectsLayer:Sprite;
		
		private var objectClassDefault:Class = Quad;
		
		private var mouseLight:PointLight;
		private var lights:Vector.<LightBase>;
		
		private var geometry:Vector.<DisplayObject>;
				
		private var nativeStage:Stage;
		private var nativeStageWidth:int = 800;
		private var nativeStageHeight:int = 600;
		
		private var helperPoint:Point = new Point();
		
		private var statusPanel:Sprite;
		private var statusString:String = "Press 'Z' to add a new Polygon.\nPress 'X' to add a new Quad.\nPress 'C' to remove some objects.\nClick to add a new light.\n\nObjects: {0}\nLights: {1}";
		
		public function BasicLightingExample()
		{
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		private function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			Starling.current.showStats = true;
			
			statusPanel = createStatusPanel();

			nativeStage = Starling.current.nativeStage;
			nativeStageWidth = nativeStage.stageWidth;
			nativeStageHeight = nativeStage.stageHeight;
			
			//create the LightLayer coverting the stage
			//this where the lights and shadows are rendered
			lightLayer = new LightLayer(nativeStageWidth, nativeStageHeight, 0x000000, 0, 1);
			objectsLayer = new Sprite();
			
			//uncomment this to add a background image with random perlin noise to see how the lights might look on a texture 
			var bmd:BitmapData = new BitmapData(nativeStageWidth, nativeStageHeight, false, 0xffffffff);
			var seed:Number = Math.floor(Math.random()*100);
			bmd.perlinNoise(320, 240, 8, seed, true, true, 7, false, null);
			addChild(new Image(Texture.fromBitmapData(bmd)));
			
			createLights();
			createGeometry();
			
			//add the lightLayer last, so it is on top of other display objects
			addChild(objectsLayer);
			addChild(lightLayer);
			addChild(statusPanel);
			
            statusPanel.x = nativeStageWidth - statusPanel.width;
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			nativeStage.addEventListener(MouseEvent.CLICK, clickHandler);
			nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
		}

		private function createLights():void
		{
			//create a white light that will follow the mouse position
			mouseLight = new PointLight(0, 0, 200, 0xffffff, 1);
			//add it to the light layer
			lightLayer.addLight(mouseLight);
			
			lights = new <LightBase>[];
			
			//create a low intensity directional light, casting shadows at a 60 degree angle
			var directionalLight:DirectionalLight = new DirectionalLight(60, 0xffffff, 0.1);
			lightLayer.addLight(directionalLight);
			
			//create a few spotlights
			var spotLight:SpotLight;
			
			spotLight = new SpotLight(0, 0, 600, 45, 60, 20, 0xff0000, 3);
			lightLayer.addLight(spotLight);
			lights.push(spotLight);

			spotLight = new SpotLight(nativeStageWidth / 2, 0, 600, 90, 60, 20, 0x00ff00, 3);
			lightLayer.addLight(spotLight);
			lights.push(spotLight);

			spotLight = new SpotLight(nativeStageWidth, 0, 600, 135, 60, 20, 0x0000ff, 3);
			lightLayer.addLight(spotLight);
			lights.push(spotLight);
			
			//uncomment this to add an arbitrary number of random lights
//			var light:Light;
//			
//			for(var i:int; i < 20; i++)
//			{
//				light = new Light(Math.random() * nativeStageWidth, Math.random() * nativeStageHeight, 200 + Math.random() * 400, Math.random() * 0xffffff, 1);
//				
//				lightLayer.addLight(light);
//				lights.push(light);
//			}
		}

		private function createGeometry():void
		{
			geometry = new <DisplayObject>[];
			
			//create an arbitrary number of objects to act as shadow geometry
			addObjects();
		}
		
		private function addObjects(useClass:Class = null, count:int = 20):void
		{
			var object:DisplayObject;
			var color:int;
			var objectClass:Class = useClass ? useClass : objectClassDefault;
			
			for (var i:int = count - 1; i >= 0; i--)
			{
				color = Math.random() * 0xffffff;
				
				if (objectClass == Polygon) {
					var r:int = 10 + Math.round(Math.random() * 10);
					var v:int = 3 + Math.round(Math.random() * 3);

					object = new Polygon(r, v, color);
					
					//this takes the bounding box of the object to create geometry that blocks light
					//the PolygonShadowGeometry class also accepts Images
					//if you want to create more complex geometry for a display object, 
					//you can make your own ShadowGeometry subclass, and override the createEdges method
					lightLayer.addShadowGeometry(new PolygonShadowGeometry(object as Polygon));
				} else if (objectClass == Quad) {
					var w:int = 10 + Math.round(Math.random() * 10);
					
					object = new Quad(w, w, color);
					
					lightLayer.addShadowGeometry(new QuadShadowGeometry(object as Quad));
				}
				
				object.pivotX = object.width >> 1;
				object.pivotY = object.height >> 1;
				
				object.x = Math.random() * nativeStageWidth;
				object.y = Math.random() * nativeStageHeight;
				
				//add the object to the stage
				//the object will cast shadows even if it is not on the display list (I might change this later)
				//to remove shadow geometry assosiated with a display object, call LightLayer.removeGeometryForDisplayObject 			
				objectsLayer.addChild(object);
				
				scaleObject(object);
				moveObject(object);
				
				geometry.push(object);
			}
			
			updateStatus(statusPanel);
		}
		
		private function removeObjects(count:int = 20):void
		{
			if (geometry.length < count) {
				return;
			}
			
			var object:DisplayObject;
			
			for (var i:int = count - 1; i >= 0; i--)
			{
				object = geometry.shift();
				objectsLayer.removeChild(object);
				lightLayer.removeGeometryForDisplayObject(object);
				
				object = null;
			}
			
			updateStatus(statusPanel);
		}
		
		private var scaleOptions:Object = {
				transition: Transitions.EASE_IN_OUT_ELASTIC,
				onComplete: scaleObject,
				onCompleteArgs: []
			};
		
		private function scaleObject(object:DisplayObject, up:Boolean = false):void {
			scaleOptions.scaleX = up ? 1 : 0.5;
			scaleOptions.scaleY = up ? 1 : 0.5;
			scaleOptions.onCompleteArgs = [object, !up];
			
			Starling.juggler.tween(object, 1 + Math.round(Math.random() * 2), scaleOptions);
		}
		
		private var moveOptions:Object = {
				transition: Transitions.EASE_OUT,
				onComplete: moveObject,
				onCompleteArgs: []
			};

		private function moveObject(object:DisplayObject):void {
			var nX:Number = Math.random() * nativeStageWidth;
			var nY:Number = Math.random() * nativeStageHeight;
			
			helperPoint.setTo(x, y);
			
			var l1:Number = helperPoint.length;
			
			helperPoint.setTo(nX, nY);
			
			var l2:Number = helperPoint.length;
			
			var time:Number = 1 + Math.round(10 * Math.abs(l1 - l2) / Math.max(nativeStageWidth, nativeStageHeight));
			
			moveOptions.x = nX;
			moveOptions.y = nY;
			moveOptions.onCompleteArgs = [object];
			
			Starling.juggler.tween(object, time, moveOptions);
		}

		private function clickHandler(event:MouseEvent):void
		{
			var light:PointLight;
			light = new PointLight(nativeStage.mouseX, nativeStage.mouseY, 100 + Math.random() * 500, Math.random() * 0xffffff, 1);
				
			lightLayer.addLight(light);
			lights.push(light);
			
			updateStatus(statusPanel);
		}
		
		private function keyPressedHandler(event:KeyboardEvent):void {
			var key:uint = event.keyCode;

			switch (key) {
				case Keyboard.Z :
					addObjects(Polygon);
					break;
				case Keyboard.X :
					addObjects(Quad);
					break;
				case Keyboard.C :
					removeObjects();
					break;
			}
		}
		
		private function update(event:EnterFrameEvent):void
		{
			mouseLight.x = nativeStage.mouseX;
			mouseLight.y = nativeStage.mouseY;
			
			/*
			var dx:int;
			var dy:int;
			var rad:Number;
			
			//rotate the objects to face the mouse position
			for each(var g:DisplayObject in geometry)
			{
				dx = g.x - mouseLight.x;
				dy = g.y - mouseLight.y;
				
				rad = -Math.atan2(dx, dy);
				g.rotation = rad;
			}
			*/
		}
		
		private function createStatusPanel(w:int = 155, h:int = 60):Sprite
		{
			var container:Sprite = new Sprite();
		    var background:Quad;
			var textField:TextField;
		
			background = new Quad(w, h, 0x0);
            textField = new TextField(w, h, "", BitmapFont.MINI, BitmapFont.NATIVE_SIZE, 0xffffff);
            textField.x = 2;
            textField.hAlign = HAlign.LEFT;
            textField.vAlign = VAlign.TOP;
            
            container.addChild(background);
            container.addChild(textField);
			
            container.blendMode = BlendMode.NONE;
			return container;
		}
		
		private function updateStatus(container:Sprite):void {
			var textField:TextField = container.getChildAt(1) as TextField;

			if (!textField) return;
			
			textField.text = formatString(statusString, geometry ? geometry.length : 0, lights ? lights.length : 0);
		}
	}
}
