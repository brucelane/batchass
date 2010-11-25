
// based on code from:
// Author : Seb Lee-Delisle
// Blog : sebleedelisle.com
package 
{
	import flash.display.Sprite;
	import flash.events.TextEvent;
	
	import org.papervision3d.cameras.CameraType;
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.view.stats.StatsView;

	
	[SWF (width="1000",height="600", backgroundColor="0x000000", frameRate="30")]
	
	public class Main extends BasicView
	{
		
		//private var plane:Plane = new Plane( null, 1000, 600 );
		private var gallery:WallGallery ;
		private var vpl:ViewportLayer;
		
		public function Main( sourceXmlFile:String = "data.xml")
		{
			super(1000,600,true,false,CameraType.FREE);
			//gallery
			//gallery = new WallGallery( plane );
			gallery = new WallGallery(  );
			addChildAt( gallery, 0 );
			//plane
			/*plane.useOwnContainer = true;
			plane.alpha = 0.1;*/
			
			//if ( DEBUG::SHOWDEBUG == 1 ) addChild( new StatsView(renderer));
			//scene.addChild( plane, "picturePlane" );
			startRendering();
		}
	}
}