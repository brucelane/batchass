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
 * Based on BitmapParticles code by André Michelle (http://www.andre-michelle.com)
 * Adapted for Onyx-VJ 4 by Bruce LANE (http://www.batchass.fr)
 * version 4.0.497 last modified March 1st 2009
 * 
 */
 package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	
	import onyx.core.*;
	import onyx.parameter.*;
	import onyx.plugin.*;

	
	[SWF(width='480', height='360', frameRate='24', backgroundColor='#FFFFFF')]
	public class BitmapParticles extends Patch
	{
		private const _source:BitmapData	= createDefaultBitmap(); 		
		[Embed(source='legologo.jpg' )] private const ImageB: Class;
		private const imageData:BitmapData = Bitmap( new ImageB() ).bitmapData;
		private const DAMP: Number = .94;
		public var preblur:Number			= 2;
		public var size:int					= 64;
		private var a:int;
		private var c:uint;
		private var _currentBlur:Number		= 2;
		private var pixels: Array;
		private var mx:Number = 50;
		private var my:Number = 50;
		public var sx:Number;
		public var sy:Number;
		public var tx:Number;
		public var ty:Number;
		public var vx:Number;
		public var vy:Number;
		public var dx:Number;
		public var dy:Number;
		public var dd:Number;
		private var intensity:Number;
		private const origin:Point = new Point();
		private var blurBitmap: Bitmap ;
		private var output:BitmapData;
		private var blurOut:BitmapData;
		private const blur:BlurFilter = new BlurFilter( 2, 2, 2 );
		private const alphaTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1, 0, 0, 0, -4 );
		private const w:int = DISPLAY_WIDTH;
		private const h:int = DISPLAY_HEIGHT;
		private var _mDown:Boolean= false;
		/**
		 * 	@constructor
		 */
		public function BitmapParticles()
		{
			Console.output('BitmapParticles 4.0.497');
			Console.output('Credits to Andre MICHELLE (http://www.andre-michelle.com)');
			Console.output('Adapted by Bruce LANE (http://www.batchass.fr)');

			parameters.addParameters(
				new ParameterNumber( 'preblur', 'preblur', 0, 30, 2, 10 ),	// Amount of Blur
				new ParameterInteger( 'size', 'size', 5, 200, size )		// Size
			) 

			pixels = new Array();
			var ox: int = ( w - imageData.width ) >> 1;
			var oy: int = ( h - imageData.height ) >> 1;
			var x: int;
			for( var y: int = 0 ; y < imageData.height ; y++ )
			{
				for( x = 0 ; x < imageData.width ; x++ )
				{
					pixels.push( new Pixel( x + ox, y + oy, imageData.getPixel32( x, y ) ) );
				}					
			}  
			output = new BitmapData( w, h, true, 0 );
			addChild( new Bitmap( output ) );
			
			blurOut = new BitmapData( w, h, true, 0 );
			
			blurBitmap = new Bitmap( blurOut );
			blurBitmap.blendMode = BlendMode.ADD;
			addChild( blurBitmap );
			addEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
		}
		/**
		 * 	@private
		 */
		 private function mouseDown(event:MouseEvent):void {
			_mDown = true;
			addEventListener(MouseEvent.MOUSE_UP, _mouseUp);		 
		} 

		/**
		 * 	@private
		 */
		private function _mouseMove(event:MouseEvent):void {
			mx = event.localX; 
			my = event.localY; 
		}
		/**
		 * 	@private
		 */
		 private function _mouseUp(event:MouseEvent):void {
			_mDown = false;
			removeEventListener(MouseEvent.MOUSE_UP, _mouseUp);
		} 
		/**
		 * 	Render graphics
		 */
		override public function render(info:RenderInfo):void {
			// clear
			graphics.clear();
			output.lock();
			blurOut.lock();
			output.fillRect( output.rect, 0x000000 );
			_currentBlur	+= preblur;
			
			if (_currentBlur >= 2) {
				var factor:int = _currentBlur - 2;
				
				_currentBlur = 0;
				_source.applyFilter(_source, DISPLAY_RECT, ONYX_POINT_IDENTITY, new BlurFilter(factor + 2,factor + 2));
			}

			_source.draw(this);
			for each( var pixel: Pixel in pixels )
			{
				sx = pixel.sx;
				sy = pixel.sy;
				vx = pixel.vx;
				vy = pixel.vy;
				
				if( _mDown )
				{
					dx = mx - sx;
					dy = my - sy;
					dd = dx * dx + dy * dy;
					
					if( dd < size * size )
					{
						dd = Math.sqrt( dd );
						dd *= 2;
	
						if( dd > 0 )
						{
							vx -= dx / dd;
							vy -= dy / dd;
						}
					}
				}
				
				dx = pixel.tx - sx;
				dy = pixel.ty - sy;
				
				vx += dx * .02;
				vy += dy * .02;
				
				vx *= DAMP;
				vy *= DAMP;
				
				sx += vx;
				sy += vy;
				
				dd = dx * dx + dy * dy;
				
				if( dd > .25 )
				{
					blurOut.setPixel32( sx + .5, sy + .5, pixel.color );
				}
				else
				{
					intensity = ( .25 - dd ) / .25;
					
					c = pixel.color;
					a = ( c >> 24 ) & 0xff;
					
					output.setPixel32( sx + .5, sy + .5, ( c & 0xffffff ) | ( ( a * intensity ) << 24 ) );
				}
				
				pixel.sx = sx;
				pixel.sy = sy;
				pixel.vx = vx;
				pixel.vy = vy;
			}
			
			blurOut.applyFilter( blurOut, blurOut.rect, origin, blur );
			blurOut.colorTransform( blurOut.rect, alphaTrans );
			
			output.unlock();
			blurOut.unlock();
			/* var transform:RenderTransform = RenderTransform.getTransform(this);
			transform.content = blurOut;
			info.source.copyPixels( transform, DISPLAY_RECT, ONYX_POINT_IDENTITY ); */
			info.source.copyPixels( blurOut, DISPLAY_RECT, ONYX_POINT_IDENTITY );
		}
		
		
		override public function  dispose():void {

			_source.dispose();
			output.dispose();
			output = null;
			blurOut.dispose();
			blurOut = null;
			
			removeEventListener(MouseEvent.MOUSE_MOVE, _mouseMove);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, _mouseUp);

			//_controls = null;
			graphics.clear();

		}
	}
}
final class Pixel
{
	public var sx: Number;
	public var sy: Number;
	public var tx: Number;
	public var ty: Number;
	
	public var vx: Number;
	public var vy: Number;
	
	public var color: int;
	
	public function Pixel( sx: Number, sy: Number, color: uint = 0xffffffff )
	{
		this.sx = tx = sx;
		this.sy = ty = sy;
		
		vx = vy = 0;
		
		this.color = color;
	}
}

final class Pixel3D
{
	public var wx: Number;
	public var wy: Number;
	public var wz: Number;
	public var rx: Number;
	public var ry: Number;
	public var rz: Number;
	
	public var c: uint;
	
	public function Pixel3D( x: Number, y: Number, z: Number, c: uint )
	{
		wx = x;
		wy = y;
		wz = z;
		
		this.c = c;
	}
}
