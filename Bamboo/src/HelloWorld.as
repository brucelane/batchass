package {
		 
		    import com.wacom.mini.core.BambooMiniDescriptorWrapper;
		    import com.wacom.mini.core.BambooMiniImpl;
		    import com.wacom.mini.core.IBambooMini;
		    import com.wacom.mini.core.IBambooMiniSystemManager;
		    import com.wacom.mini.core.IBridgedBambooMini;
		    import com.wacom.mini.core.locale.ISimpleResourceManager;
		    import com.wacom.mini.flash.FlashFactory;
		    
		    import flash.display.Sprite;
		    import flash.events.IEventDispatcher;
		    import flash.text.TextField;
		 
		    public class HelloWorld extends Sprite implements IBambooMiniSystemManager, IBridgedBambooMini {
			 
			        private var _bambooDockBridge : IBambooMini;
			 
			        public function HelloWorld() {
				            _bambooDockBridge = new BambooMiniImpl(this, new FlashFactory(), 500, 200);
							var label : TextField = new TextField();
								    label.x = 100;
								    label.y = 100;
								    label.textColor = 0xffffff;
								    label.text = "Hello World";
								 
								    addChild(label);
				        }
			 
			        public function get application() : * {
				            return this;
				        }
			 
			        public function get bambooDockBridge() : IBambooMini {
				            return _bambooDockBridge;
				        }
			 
			        /**
			         * The following code usage is deprecated, but it guarantees
			         * compatibility with Bamboo Dock 3.1.5.
			         * Please make sure to include it in your implementation.
			         */
			 
			        public function get bambooResourceManager() : ISimpleResourceManager
			        {
			            return bambooDockBridge.bambooResourceManager; 
		        }
			         
			        public function set inMDL(value : Boolean) : void { }
			         
			        public function set localeProvider(value : IEventDispatcher) : void
			        {
				            bambooDockBridge.localeProvider = value;   
				        }
			         
			        public function set bambooMiniDescriptor(value : *) : void
			        {
				            bambooDockBridge.bambooMiniDescriptor = value; 
				        }
			         
			        public function getBambooMiniDescriptor() : BambooMiniDescriptorWrapper
			        {
				            return bambooDockBridge.getBambooMiniDescriptor();
				        }
			    }
		}