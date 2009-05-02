package libs
{
	import mx.preloaders.DownloadProgressBar;
    import flash.events.ProgressEvent;

	public class Chargement extends DownloadProgressBar
	{
		public function Chargement()
		{
			super();
			backgroundColor=0xFFFFFF;
			//backgroundImage="images/pradet.gif"
            // Set the download label.
            downloadingLabel="Chargement..."
            // Set the initialization label.
            initializingLabel="Initialisation..."
            // Set the minimum display time to 2 seconds.
            //MINIMUM_DISPLAY_TIME=4000;
		}
        // Override to return true so progress bar appears
        // during initialization.       
        override protected function showDisplayForInit(elapsedTime:int, 
            count:int):Boolean {
                return true;
        }

        // Override to return true so progress bar appears during download.     
        override protected function showDisplayForDownloading(
            elapsedTime:int, event:ProgressEvent):Boolean {
                return true;
        }
		
	}
}
