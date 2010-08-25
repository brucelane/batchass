
import fr.batchass.AIRUpdater;

import mx.events.FlexEvent;

protected function vpDude_creationCompleteHandler(event:FlexEvent):void
{
	//check for update or update if downloaded
	AIRUpdater.checkForUpdate();
}
