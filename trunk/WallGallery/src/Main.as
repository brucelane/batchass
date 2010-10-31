package 
{
	import flash.display.Sprite;
	import flash.events.TextEvent;
	
	import org.papervision3d.objects.primitives.Plane;
	import org.papervision3d.view.BasicView;
	import org.papervision3d.view.stats.StatsView;

	
	[SWF (width="800",height="480", backgroundColor="0x000000", frameRate="30")]
	
	public class Main extends BasicView
	{
		
		private var plane:Plane = new Plane();
		private var gallery:WallGallery ;
		
		public function Main( sourceXmlFile:String = "data.xml")
		{
			scene.addChild( plane );
			gallery = new WallGallery( plane );
			addChild( gallery );
			addEventListener( gallery.PLANE_CHANGED, planeChanged );
			//addChildAt( new WallGallery(), 0 );
			addChild( new StatsView(renderer));
			startRendering();
		}
		private function planeChanged( evt:TextEvent ):void
		{
			trace("main plane chg" + evt.text);
			//plane.setChildMaterial( 
		}
	}
}