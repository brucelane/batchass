
// based on code from:
// Author : Seb Lee-Delisle
// Blog : sebleedelisle.com
package 
{
	import flash.display.Sprite;
	import flash.events.TextEvent;
	
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.stats.StatsView;

	
	[SWF (width="1000",height="600", backgroundColor="0x000000", frameRate="30")]
	
	public class Main extends BasicView
	{
		
		private var plane:Plane = new Plane( null, 1000, 600 );
		private var gallery:WallGallery ;
		private var vpl:ViewportLayer;
		//public var mainScene:Scene3D;
		
		public function Main( sourceXmlFile:String = "data.xml")
		{
			//gallery
			gallery = new WallGallery( plane );
			addChildAt( gallery, 0 );
			//plane
			plane.useOwnContainer = true;
			plane.alpha = 0.1;
			
			//addEventListener( gallery.PLANE_CHANGED, planeChanged );
			addChild( new StatsView(renderer));
			scene.addChild( plane, "picturePlane" );
			//mainScene = scene;
			//viewportlayer
			/*vpl = viewport.getChildLayer( plane );
			vpl.forceDepth = true;
			vpl.screenDepth = 2000;*/
			
			startRendering();
		}
		/*private function planeChanged( evt:TextEvent ):void
		{
			trace("main plane chg" + evt.text);
			//plane.setChildMaterial( 
		}*/
	}
}