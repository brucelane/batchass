package plugins.visualizer {
// Author: Pierluigi Pesenti
// Web: http://blog.oaxoa.com
 
import flash.media.Sound;
import flash.net.URLRequest;
import flash.media.SoundMixer;
import flash.utils.ByteArray;
import flash.events.*;
import flash.display.Sprite;
import flash.filters.GlowFilter;
//import com.oaxoa.components.FrameRater;

	public class ParticleVisualizer extends Sprite
	{
		private var req:URLRequest=new URLRequest("vegas.mp3");
		private var sound:Sound=new Sound(req);
		private var ba:ByteArray=new ByteArray();
		private var samples:uint=32;
		private var offset:uint=256/samples;
		 
		// create a sprite and add 1*samples istances of the SimpleParticleGenerator class
		private var _holder:Sprite=new Sprite();
		public function ParticleVisualizer()
		{
			for(var i:uint=0; i<samples; i++) {
				var pg:SimpleParticleGenerator=new SimpleParticleGenerator();
				pg.y=252;
				pg.x=15+i*offset*2;
				pg.angleDeg=-90;
				_holder.addChild(pg);
			}
			 
			// add the holder sprite and start music
			addChild(_holder);
			sound.play();
			// listener for frame based animation
			addEventListener(Event.ENTER_FRAME, onframe);
			// some fancy glow filter
			// the glow filter is added to the holder sprite
			// and not to the single particle for two reasons
			// a lot of speed gain, and visually better blend result
			var glow:GlowFilter=new GlowFilter();
			glow.color=0xFFAA00;
			_holder.filters=[glow];
		}
 
 
 
 
// at every frame
function onframe(event:Event):void {
	// compoute sound specturm
	SoundMixer.computeSpectrum(ba, true);
	var count:uint=0;
	//for every generator
	// with a 0-256 range only the left channel is sampled
	// you can easily goto from 256 to 512 for the right or sample both and average value
	for (var i:uint=0; i<256; i+=offset) {
		var t:Number=ba.readFloat();
		var n:Number=t*20;
		var g=_holder.getChildAt(count);
		// set the particles speed at a value of n
		// n = the sound peak * 20 to raise the effect
		g.speed=n;
		count++;
	}
}
 
//add frame rate meter
/* var fr:FrameRater=new FrameRater(0xffFFFF, false, true, 0x0099ff);
addChild(fr); */
	}
}
import flash.display.Shape;
	
final class SimpleParticle extends Shape {
	
	public function SimpleParticle() {
		// just extending Shape class with dynamic features
	}
}

import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.Stage;

	final class SimpleParticleGenerator extends Sprite {

		private var _speed:Number;
		private var _angleDeg:Number;
		private var _particles:Array;
		
		public function SimpleParticleGenerator() {
			// start animating (frame based)
			addEventListener(Event.ENTER_FRAME, update);
			// start adding Particles (timer based)
			var timer:Timer=new Timer(10, 0);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			_particles=new Array();
		}
		private function onTimer(event:TimerEvent):void {
			for (var i:uint=0; i<2; i++) {
				addParticle();
			}
		}
		
		public function addParticle():void {
			var shape:SimpleParticle=new SimpleParticle();
			shape.graphics.beginFill(0xffffff);
			shape.graphics.drawCircle(0,0,1);
			shape.graphics.endFill();

			addChild(shape);
			var scale:Number=2;

			var gravSpeed:Number=0;
			var acc:Number=0;
			
			var spread:Number=Math.random()*6;
			spread-=3;
			
			var angle:Number=(angleDeg+spread) / 180 * Math.PI;
			var age:uint=0;

			shape.gravSpeed=gravSpeed;
			shape.acc=acc;
			shape.speed=Math.random()*(speed*.2)+speed*.8;
			shape.angle=angle;
			shape.scale=scale;
			shape.age=age;

			shape.scaleX=shape.scaleY=scale;
			_particles.push(shape);
		}
		
		public function update(event:Event):void {
			var gravAcc:Number=0.8;
			for (var i:uint=0; i<_particles.length; i++) {
				var t=_particles[i];
				t.speed+=t.acc;
				t.gravSpeed+=gravAcc;
				var incx:Number=Math.cos(t.angle)*t.speed;
				t.x+=incx;
				t.y+=Math.sin(t.angle)*t.speed;
				t.y+=Math.sin(90)*t.gravSpeed;
				t.age++;
				t.alpha=1-(t.age/30);
				if (t.age>30 || t.y>0) {
					removeChild(t);
					_particles[i]=null;
					_particles.splice(i, 1);
				}
			}
		}
		
		// setters & getters
		
		public function set speed(n:Number):void {
			_speed=n;
		}
		public function get speed():Number {
			return _speed;
		}
		
		public function set angleDeg(n:Number):void {
			_angleDeg=n;
		}
		public function get angleDeg():Number {
			return _angleDeg;
		}
	}
