/**
 * Copyright (c) 2003-2008 "Onyx-VJ Team" which is comprised of:
 *
 * Daniel Hai
 * Stefano Cottafavi
 *
 * All rights reserved.
 *
 * Licensed under the CREATIVE COMMONS Attribution-Noncommercial-Share Alike 3.0
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at: http://creativecommons.org/licenses/by-nc-sa/3.0/us/
 *
 * Please visit http://www.onyx-vj.com for more information
 *  
 * Based on Branches code by Pierluigi PESENTI (http://blog.oaxoa.com/)
 * Adapted for Onyx-VJ 4 by Bruce LANE (http://www.batchass.fr)
 * version 4.0.510 last modified August 10, 2009
 * 
 * un zoom arriere partant de quarks qui s'entrechoquent 
 * et forment un noyau puis des electrons qui viennent tourner autour, 
 * ensuite les atomes s'assemblent en molecules, 
 * puis ca devient des blobs de cellules 
 * qui forment un tissus puis une graine 
 * et une plante qui pousse et les branches 
 * qui se developpent et la foret qui grandit...
 * des atomes qui se repoussent et s'attirent 
 * et qui forment un chat qui le chat se fritte avec un autre chat 
 * et un humain jette une godasse sur le chat, 
 * puis l'humain se frite avec sa femme 
 * et les voisins tapent contre le mur et dans le quartier, 
 * ya des voyous qui s'embrouillent et les keufs s'en melent 
 * et pendant ce temps, dans un pays a cote, 
 * ya une guerre et sur toute la planete ca se chamaille 
 * avec les animaux qui bouffent les autres et 
 * les humains qui se bouffent puis la cam 
 * recule encore jusqu'a l'espace et la..... silence..... rien.... 
 * la terre tourne lentement autour du soleil..... et la..... 
 * une meteorite qui fait un carreau sur la terre 
 * et qui la bazarde a l'autre bout du cosmos sur un autre orbite.
 */
 package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import onyx.core.*;
	import onyx.events.InteractionEvent;
	import onyx.parameter.*;
	import onyx.plugin.*;

	
	[SWF(width='320', height='240', frameRate='24', backgroundColor='#00FFFF')]
	final public class DrawBranches extends Patch 
	{
		private const source:BitmapData	= createDefaultBitmap(); 
		private const branches:Array = [];
		public var  amount:int = 10;
		private var last:Point = new Point(0, 0);
		public var lineColor:uint			= 0x5533FF;
		private var _currentBlur:Number		= 0;
		private const filter:BlurFilter		=  new BlurFilter(0, 0);
		public var preblur:Number			= .4;
		public var    conn:Socket;
		private var   _host:String;
		private var   _port:String;
		private var   _timer:Timer;
		private var   _attempts:int;
		
		/**
		 * 	@constructor
		 */
		public function DrawBranches()
		{
			Console.output('DrawBranches 4.0.510');
			Console.output('Credits to Pierluigi PESENTI');
			Console.output('Adapted by Bruce LANE (http://www.batchass.fr)');
			parameters.addParameters( 
				new ParameterColor('lineColor', 'lineColor'),
				new ParameterNumber('preblur', 'preblur', 0, 30, 0, 10),
				new ParameterNumber('amount', 'max branches', 0, 30, 0, 1)
			);
			//buildBranches();
			addEventListener(InteractionEvent.MOUSE_DOWN, mouseDown);
			_host = '127.0.0.1';
			_port = '10000';
			conn     = new Socket();
            
            _attempts = 0;
                
		    conn.addEventListener(Event.CONNECT, handleSocketConnected);
		    conn.addEventListener(Event.CLOSE, handleSocketClose);
            conn.addEventListener(ProgressEvent.SOCKET_DATA, handleProgress);
            conn.addEventListener(IOErrorEvent.IO_ERROR, handleSocketIOError);
            conn.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSocketSecurityError);
            
            // connect
            connect();
		}
		public function connect():void {
            
            // 10sec timeout
            if(_attempts<10) {
            	_attempts += 1;
	            try{
	            	Console.output('MIDI Module: attempt '+_attempts+' on '+_host+'@'+_port);
	                conn.connect(_host, int(_port));
	            } catch (e : SecurityError) {
	            	_scheduleReconnect()
	            }
	       	} else {
	       		Console.output('MIDI Module: network down');
	       		_attempts = 0;
	       	}
	       	
	    }
	    public function get connected():Boolean {
        	return conn.connected;
        }
		
		private function _reconnect(event:Event): void {
            _timer.removeEventListener(TimerEvent.TIMER, _reconnect);
            _timer.stop();
            _timer = null;
            connect();
        }
        private function _scheduleReconnect():void {
            _timer = new Timer(1000,1);
            _timer.addEventListener(TimerEvent.TIMER, _reconnect);
            _timer.start();
        }
		private function handleSocketConnected(e : Event) : void {
            Console.output('MIDI Module: connected');
            _attempts = 0;
        }
        
        private function handleSocketIOError(e : IOErrorEvent) : void {
        	Console.output("MIDI Module: unable to connect, socket error");
        	_scheduleReconnect();
        }
        
        private function handleSocketSecurityError(e : SecurityErrorEvent) : void {
            Console.output('MIDI Module: security error');
        }
        
        private function handleSocketClose(e:Event):void {
        	Console.output('MIDI Module: connection lost');
       		_scheduleReconnect();
        }
        
        
        private function handleProgress(event:ProgressEvent):void {
            
            var n:int = event.bytesLoaded;
            var data:ByteArray = new ByteArray();
            
            conn.readBytes(data,0,n);
            
            // SC: TODO...n==3 very restrictive due to startup errors!!
            if(n==3) receiveMessage(data);
            
        }
		/**
		 *    Receive MIDI message from controller(via proxy)
		 */
		public static function receiveMessage(data:ByteArray):void {
			
            var status:uint      = data.readUnsignedByte();
			var command:uint     = status&0xF0;
			var channel:uint     = status&0x0F; 
			var data1:uint       = data.readUnsignedByte();
			var data2:uint       = data.readUnsignedByte();
		      
		    var midihash:uint    = ((status<<8)&0xFF00) | data1&0xFF;
			
			//var behavior:IMidiControlBehavior = _map[midihash]; 
			Console.output( "Midi receiveMessage s:" + status + " cmd:" + command + " chan:" + channel + " data1:" + data1 + " data2:" + data2);
			//Console.output('Midi RCV');
							
			/* if(behavior) {
			     switch(command) {
	                case NOTE_OFF:
	                case NOTE_ON:
	                    behavior.setValue(data1);
	                    break;
	                case CONTROL_CHANGE:
	                    behavior.setValue(data2);
	                    break;
	                
	                default:
                 }
			}
            
            if(instance.hasEventListener(MidiEvent.DATA)) {
            	
            	REUSABLE.command        = command;
                REUSABLE.channel        = channel;
                REUSABLE.data1          = data1;
                REUSABLE.data2          = data2;
                
                REUSABLE.midihash       = midihash;
                
                instance.dispatchEvent(REUSABLE);
                
            } */
		}	
		/**
		 *    log to file
		 */
		/* public static function log( text:String, clear:Boolean=false ):void
		{
		    var file:File = File.applicationStorageDirectory.resolvePath( nowDate + ".txt" );
		    var fileMode:String = ( clear ? FileMode.WRITE : FileMode.APPEND );
		
		    var fileStream:FileStream = new FileStream();
		    fileStream.open( file, fileMode );
		
		    fileStream.writeMultiByte( text + "\t", File.systemCharset );
		    fileStream.close();
		    
		} */
		private function mouseDown(event:MouseEvent):void {
			
			addEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
			//addEventListener(MouseEvent.MOUSE_UP, _mouseUp);
			
			last.x = event.localX;
			last.y = event.localY;
			//Console.output('mouseDown' + last.x);
        	Console.output('MIDI Module: ' + conn.connected);
			lineColor+=30;
			buildBranches();
			_mouseMove(event);
		}
		private function _mouseMove(event:MouseEvent):void {
			last.x = event.localX;
			last.y = event.localY;
			buildBranches();
		}
		private function _mouseUp(event:MouseEvent):void {
			/* removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, _mouseUp); */
		}
		override public function render(info:RenderInfo):void {
			_currentBlur	+= preblur;
			var factor:int = _currentBlur - 2;
			if (_currentBlur >= 2) _currentBlur = 0;
			filter.blurX = factor + 2;
			filter.blurY = factor + 2;
			source.applyFilter(source, DISPLAY_RECT, ONYX_POINT_IDENTITY, filter);
			//Console.output("branches:" + branches.length.toString());
			for each (var branch:Branch in branches) {
				if ( !branch.ended ) branch.render(source);// else branch.dispose();//branches.pop();}
				
			}
			// copy to the layer
			info.source.copyPixels(source, DISPLAY_RECT, ONYX_POINT_IDENTITY);
			
		}  
		
		private function buildBranches():void {
			//for (var count:int = branches.length; count < _amount; count++) {
				var newBranch:Branch = new Branch();
				newBranch.xSrc = last.x;
				newBranch.ySrc = last.y;
				newBranch.lineColor = lineColor;
				branches.push(newBranch);
			//}
			
			while (branches.length > amount) {
				var branch:Branch = branches.shift();
				branch.dispose();
			}  
		}
		
		override public function dispose():void {

			source.dispose();
			
			for each (var branch:Branch in branches) {
				branch.dispose();
			}
		}		
	}// Class
} //Package

//Branch class
import flash.events.Event;
import flash.geom.Point;

import flash.filters.BevelFilter;
import flash.display.*;
import onyx.core.*;
import onyx.plugin.*;
import flash.geom.Matrix;
import flash.media.Microphone;
final class Branch extends Sprite implements IDisposable {
	
	private var power:Number;
	private var decay:Number;
	private var seed:uint=Math.random()*999;
	private var bd:BitmapData;
	private var bmp:Bitmap;
	private var offsets:Array;
	
	private var line:Sprite;
	private var tx:Number;
	private var ty:Number;
	
	private var angle:Number;
	private var angleRadians:Number;
	
	private var maxRotSpeed:Number=50;
	
	private var colorValue:uint;
	private var rotSpeed:Number;
	
	private var r:Number;
	private var lum:uint;
	private var grey:uint;
	
	private var bevel:BevelFilter;
	private var perlinSize:Number;
	public var lineColor:uint = 0xFF0000;
	public var xSrc:int = 160;
	public var ySrc:int = 120;
	public var ended:Boolean = false;
		
	private const matrix:Matrix	= new Matrix();

	public function Branch(pperlinSize:Number=20) {
		perlinSize=pperlinSize;
		bd=new BitmapData(1, 1, false);
		bmp=new Bitmap(bd);
		
		offsets=[new Point(0,0), new Point(0,0)];
		
		lum=Math.random()*255;
		grey=lum<<16 | lum<<8 |lum;
		tx=ty=0;
		angle=Math.random()*360;
		power=Math.random()*8;
		decay=(90+Math.random()*9)/100;
		lum=Math.random()*255;
		
		line=new Sprite();
		line.graphics.moveTo(0,0);
		addChild(line);
		//addEventListener(Event.ENTER_FRAME, onframe);
	}
	

	public function render(source:BitmapData):void {
		matrix.a = 1;//Scale
		matrix.b = 0;
		matrix.c = 0;
		matrix.d = 1;//Scale
		matrix.tx = xSrc;
		matrix.ty = ySrc;
		for(var i:uint=0; i<3; i++) grow();
		source.draw(line, matrix, null, null, null, true);
	}
	/* public function onframe(event:Event):void {
		for(var i:uint=0; i<3; i++) grow();
	} */
	public function grow():void {
		power*=decay;
		r=power;

		if(r<.3) stopThis();
		offsets[0].x+=1;
		offsets[0].y-=.4;
		
		offsets[1].x-=.3;
		offsets[1].y=.1;
		
		bd.perlinNoise(perlinSize, perlinSize, 2, seed, false, true, 7, true, offsets);
		colorValue=bd.getPixel(0,0)>>16;
		rotSpeed=(-128+colorValue)/255*maxRotSpeed;

		angle+=rotSpeed;
		angleRadians=angle/180*Math.PI;

		tx+=Math.cos(angleRadians)*power;
		ty+=Math.sin(angleRadians)*power;
		
		line.graphics.lineStyle(r*1.5, lineColor);
		line.graphics.lineTo(tx,ty);
	}
	
	public function stopThis():void {
		//removeEventListener(Event.ENTER_FRAME, onframe);
		//this.dispose();
		//line.graphics.clear;
		ended = true;
		dispatchEvent(new Event(Event.COMPLETE));
	}
	public function dispose():void {
		line = null;
		graphics.clear();
	}
}

