package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import tv.ustream.gui2.Button;
	import tv.ustream.gui2.Label;
	import tv.ustream.tools.Debug;
	import tv.ustream.tools.IdValidator;
	import tv.ustream.viewer.logic.Logic;
	
	public class UStreamAir extends Sprite 
	{
		private var inputTf:TextField;
		private var btn:Button;
		private var logic:Logic;
		
		public function UStreamAir():void 
		{
			if (stage) onAddedToStage();
			else addEventListener('addedToStage', onAddedToStage);
		}
		
		private function onAddedToStage(...e):void
		{
			logic = new Logic()
			addChild(logic.display)
			
			with (addChild(inputTf = new TextField()))
			{
				defaultTextFormat = new TextFormat('courier', 15, 0x4590b7)
				multiline = wordWrap = false
				x = 10
				y = 10
				width = 380
				height = 20
				border = true
				borderColor = 0x4590b7
				type = 'input'
			}
			stage.focus = inputTf
			inputTf.text = "1996140";
			
			with (addChild(btn = new Button('Ok')))
			{
				x = 10
				y = 30
				addEventListener('click',onBtnClick)
			}
			
			stage.align = 'TL'
			stage.scaleMode = 'noScale'
			stage.addEventListener('resize', onStageResize)
			onStageResize()
		}
		
		private function onStageResize(...e):void 
		{
			inputTf.width = stage.stageWidth - inputTf.x * 2
			logic.display.width = stage.stageWidth
			logic.display.height = stage.stageHeight
		}
		
		private function onBtnClick(...e):void 
		{
			var idValidator:IdValidator = new IdValidator()
			try
			{
				idValidator.parseId(inputTf.text)
				getPlayer(inputTf.text)
			}
			catch (e:Error)
			{
				inputTf.text = e.toString()
				stage.focus = inputTf
				inputTf.setSelection(0,inputTf.length)
			}
		}
		
		private function getPlayer(id:String):void
		{
			inputTf.visible = btn.visible = false
			logic.createChannel(inputTf.text)
		}
	}
}