/*
VERSION: 5.87
DATE: 1/8/2008
ACTIONSCRIPT VERSION: 3.0 (AS2 version is available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenFilterLite.com (has link to AS3 version)
DESCRIPTION:
	TweenFilterLite extends the extremely lightweight (about 2k), powerful TweenLite "core" class, adding the ability to tween filters (like blurs, 
	glows, drop shadows, bevels, etc.) as well as image effects like contrast, colorization, brightness, saturation, hue, and threshold (combined size: about 6k). 
	The syntax is identical to the TweenLite class. If you're unfamiliar with TweenLite, I'd highly recommend that you check it out. 
	It provides easy way to tween multiple object properties over time including a MovieClip's position, alpha, volume, color, etc. 
	Just like the TweenLite class, TweenFilterLite allows you to build in a delay, call any function when the tween starts or has completed
	(even passing any number of parameters you define), automatically kill other tweens that are affecting the same object (to avoid conflicts),
	tween arrays, etc. One of the big benefits of this class (and the reason "Lite" is in the name) is that it was carefully built to 
	minimize file size. There are several other Tweening engines out there, but in my experience, they required more than triple the 
	file size which was unacceptable when dealing with strict file size requirements (like banner ads). I haven't been able to find a 
	faster tween engine either. The syntax is simple and the class doesn't rely on complicated prototype alterations that can cause 
	problems with certain compilers. TweenFilterLite is simple, very fast, and more lightweight than any other popular tweening engine with similar features.

ARGUMENTS:
	1) $mc: Target DisplayObject (typically a MovieClip or Sprite) whose properties we're tweening
	2) $duration: Duration (in seconds) of the effect
	3) $vars: An object containing the end values of all the properties you'd like to have tweened (or if you're using the 
	      	 TweenFilterLite.from() method, these variables would define the BEGINNING values). Examples are: blurX, blurY, contrast,
		  	 color, distance, colorize, brightness, highlightAlpha, etc. Make sure you define a type property. Possible value are:
		  	 "blur", "glow", "dropShadow", "bevel", and "color". (see below for more specifics)
		        SPECIAL PROPERTIES: 
				  delay: Amount of delay before the tween should begin (in seconds).
				  ease: You can specify a function to use for the easing with this variable. For example, 
						fl.motion.easing.Elastic.easeOut. The Default is Regular.easeOut (and Linear.easeNone for volume).
				  easeParams: An array of extra parameters to feed the easing equation. This can be useful when you 
					  			  use an equation like Elastic and want to control extra parameters like the amplitude and period.
								  Most easing equations, however, don't require extra parameters so you won't need to pass in any easeParams.
				  autoAlpha: Same as changing the "alpha" property but with the additional feature of toggling the "visible" property 
				  			 to false if the alpha ends at 0. It will also toggle visible to true before the tween starts if the value 
							 of autoAlpha is greater than zero.
				  volume: To change a MovieClip's volume, just set this to the value you'd like the MovieClip to
						  end up at (or begin at if you're using TweenLite.from()).
				  tint: To change a MovieClip's color, set this to the hex value of the color you'd like the MovieClip
					  	to end up at(or begin at if you're using TweenLite.from()). An example hex value would be 0xFF0000. 
						If you'd like to remove the color from a MovieClip, just pass null as the value of tint.
				  onStart: If you'd like to call a function as soon as the tween begins, pass in a reference to it here.
						   This is useful for when there's a delay. 
				  onStartParams: An array of parameters to pass the onStart function. (this is optional)
				  onUpdate: If you'd like to call a function every time the property values are updated (on every frame during
							the time the tween is active), pass a reference to it here.
				  onUpdateParams: An array of parameters to pass the onUpdate function (this is optional)
				  onComplete: If you'd like to call a function when the tween has finished, use this. 
				  onCompleteParams: An array of parameters to pass the onComplete function (this is optional)
				  overwrite: If you do NOT want the tween to automatically overwrite any other tweens that are 
							 affecting the same target, make sure this value is false.

	
FITLERS & PROPERTIES:
	type:"blur"
		Possible properties: blurX, blurY, quality
		
	type:"glow"
		Possible properties: alpha, blurX, blurY, color, strength, quality, inner, knockout
	
	type:"color"
		Possible properties: colorize, amount, contrast, brightness, saturation, hue, threshold, relative
	
	type:"dropShadow"
		Possible properties: alpha, angle, blurX, blurY, color, distance, strength, quality
	
	type:"bevel"
		Possible properties: angle, blurX, blurY, distance, highlightAlpha, highlightColor, shadowAlpha, shadowColor, strength, quality
	

EXAMPLES: 
	As a simple example, you could tween the blur of clip_mc from where it's at now to 20 over the course of 1.5 seconds by:
		
		import gs.TweenFilterLite;
		TweenFilterLite.to(clip_mc, 1.5, {type:"blur", blurX:20, blurY:20});
	
	To set up a sequence where we colorize a MovieClip red over the course of 2 seconds, and then blur it over the course of 1 second,:
	
		import gs.TweenFilterLite;
		TweenFilterLite.to(clip_mc, 2, {type:"color", colorize:0xFF0000, amount:1});
		TweenFilterLite.to(clip_mc, 1, {type:"blur", blurX:20, blurY:20, delay:2, overwrite:false});
		
	If you want to get more advanced and tween the clip_mc MovieClip over 5 seconds, changing the saturation to 0, 
	delay starting the whole tween by 2 seconds, and then call a function named "onFinishTween" when it has 
	completed and pass in a few arguments to that function (a value of 5 and a reference to the clip_mc), you'd 
	do so like:
		
		import gs.TweenFilterLite;
		import fl.motion.easing.Back;
		TweenFilterLite.to(clip_mc, 5, {type:"color", saturation:0, delay:2, onComplete:onFinishTween, onCompleteParams:[5, clip_mc]});
		function onFinishTween(argument1:Number, argument2:MovieClip):void {
			trace("The tween has finished! argument1 = " + argument1 + ", and argument2 = " + argument2);
		}
	
	If you have a MovieClip on the stage that already has the properties you'd like to end at, and you'd like to 
	start with a colorized version (red: 0xFF0000) and tween to the current properties, you could:
		
		import gs.TweenFilterLite;
		TweenFilterLite.from(clip_mc, 5, {type:"color", colorize:0xFF0000});		
	

NOTES:
	- This class (along with the TweenLite class which it extends) will add about 6kb total to your Flash file.
	- Requires that you target Flash 9 Player or later (ActionScript 3.0).
	- Instead of using "100" as the base number for most values (like brightness, contrast, saturation, etc.) like the ActionScript 2.0 
	  version of this class did, we now use "1" in order to be consistent with the rest of ActionScript 3.0.
	- Quality defaults to a level of "2" for all filters, but you can pass in a value to override it.
	- This class requires the gs.TweenLite class.
	- The image filter (type:"color") functions were built so that you can leverage this class to manipulate matrixes for the
	  ColorMatrixFilter by calling the static functions directly (so you don't necessarily have to be tweening 
	  anything). For example, you could colorize a matrix by:
	  var myNewMatrix:Array = TweenFilterLite.colorize(myOldMatrix, 0xFF0000, 100);
	- Special thanks to Mario Klingemann (http://www.quasimondo.com) for the work he did on his ColorMatrix class.
	  It was very helpful for the image effects.

	  
CHANGE LOG:
	5.86 and 5.87:
		- Fixed potential 1010 errors when an onUpdate() calls a killTweensOf() for an object.
	5.85:
		- Fixed 1010 and 1009 errors that popped up sometimes when TweenFilterLite was used for non-filter tweens. Ideally it is better to use TweenLite for those, but not everyone realizes that.
	5.84:
		- Fixed an issue that prevented TextField filters from being applied properly.
	5.81:
		- Added the ability to define extra easing parameters using easeParams.
		- Changed "mcColor" to "tint" in order to make it more intuitive. Using mcColor for tweening color values is deprecated and will be removed eventually.
	5.7: 
		- Improved speed
	5.6 and 5.5:
		- Fixed very rare, intermittent 1010 errors
	5.3:
		- Added onUpdate and onUpdateParams features
		- Finally removed extra/duplicated (deprecated) constructor parameters that had been left in for almost a year simply for backwards compatibility.
	  
CODED BY: Jack Doyle, jack@greensock.com
Copyright 2007, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs {
	import gs.TweenLite;
	import flash.filters.*;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	
	public class TweenFilterLite extends TweenLite {
		public static var version:Number = 5.87;
		public var _matrix:Array;
		private var _mc:DisplayObject;
		private var _f:BitmapFilter; //Filter
		private var _fType:Class = TweenFilterLite; //in the render() function, we check for the _fType and if we don't set it to something here, it'll throw 1010 or 1009 errors. Typically it'll be a type of filter, like BlurFilter which gets set in the initTweenVals() function.
		private var _clrsa:Array; //Array that pertains to any color properties (like "color", "highlightColor", "shadowColor", etc.)
		private var _endMatrix:Array;
		private var _clrMtxTw:TweenLite; //The tween that's handling the Color Matrix Filter (if any)
		private static var _idMatrix:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
		private static var _lumR:Number = 0.212671; //Red constant - used for a few color matrix filter functions
		private static var _lumG:Number = 0.715160; //Green constant - used for a few color matrix filter functions
		private static var _lumB:Number = 0.072169; //Blue constant - used for a few color matrix filter functions
		public static var delayedCall:Function = TweenLite.delayedCall; //Otherwise TweenFilterLite.delayedCall() would throw errors (it's a static method of TweenLite)
		public static var killTweensOf:Function = TweenLite.killTweensOf; //Otherwise TweenFilterLite.killTweensOf() would throw errors (it's a static method of TweenLite)
		public static var killDelayedCallsTo:Function = TweenLite.killTweensOf; //Otherwise TweenFilterLite.killDelayedCallsTo() would throw errors (it's a static method of TweenLite)
		
		public function TweenFilterLite($mc:DisplayObject, $duration:Number, $vars:Object) {
			super($mc, $duration, $vars);
			if ($mc == null) {return};
			_mc = $mc;
			_clrsa = [];
			if (this.vars.runBackwards == true) { //Keep in mind that when the duration is 0, the TweenLite constructor will force the runBackward property to be true so that the values will be immediately rendered. It will also call the removeTween() method.
				initTweenVals();
			}
			if (TweenLite.version < 5.87 || isNaN(TweenLite.version)) {
				trace("ERROR! Please update your TweenLite class. TweenFilterLite requires a more recent version. Download updates at http://www.TweenLite.com.");
			}
		}
		
		public static function to($mc:DisplayObject, $duration:Number, $vars:Object):TweenFilterLite {
			return new TweenFilterLite($mc, $duration, $vars);
		}
		
		//This function really helps if there are MovieClips whose filters we want to animate into place (they are already in their end state on the stage for example). 
		public static function from($mc:DisplayObject, $duration:Number, $vars:Object):TweenFilterLite {
			$vars.runBackwards = true;
			return new TweenFilterLite($mc, $duration, $vars);
		}
		
		override public function initTweenVals():void {
			if (_mc != null) { //Otherwise it runs in the superconstructor before we can set the _mc
				super.initTweenVals();
				if (this.vars.type != null) {
					var i:int;
					_clrsa = [];
					_matrix = _idMatrix.slice();
					if (this.vars.quality == undefined || isNaN(this.vars.quality)) {
						this.vars.quality = 2;
					}
					if (this.vars.runBackwards == true) {
						for (var p:String in this.tweens) {
							this.tweens[p].flipped = true; //Gives us a way to identify the tweens that were already flipped in the initTweenVals() call. We only need to flip the new ones we're adding below (later)...
						}
					}
					switch(this.vars.type.toLowerCase()) {
						case "blur":
							setFilter(BlurFilter, ["blurX", "blurY", "quality"], new BlurFilter(0, 0, this.vars.quality));
							break;
						case "glow":
							setFilter(GlowFilter, ["alpha", "blurX", "blurY", "color", "quality", "strength", "inner", "knockout"], new GlowFilter(0xFFFFFF, 0, 0, 0, this.vars.strength || 1, this.vars.quality, this.vars.inner, this.vars.knockout));
							break;
						case "colormatrix":
						case "color":
						case "colormatrixfilter":
						case "colorize":
							setFilter(ColorMatrixFilter, [], new ColorMatrixFilter(_matrix));
							_matrix = ColorMatrixFilter(_f).matrix;
							if (this.vars.relative == true) {
								_endMatrix = _matrix.slice();
							} else {
								_endMatrix = _idMatrix.slice();
							}
							_endMatrix = setBrightness(_endMatrix, this.vars.brightness);
							_endMatrix = setContrast(_endMatrix, this.vars.contrast);
							_endMatrix = setHue(_endMatrix, this.vars.hue);
							_endMatrix = setSaturation(_endMatrix, this.vars.saturation);
							_endMatrix = setThreshold(_endMatrix, this.vars.threshold);
							if (!isNaN(this.vars.colorize)) {
								_endMatrix = colorize(_endMatrix, this.vars.colorize, this.vars.amount);
							} else if (!isNaN(this.vars.color)) { //Just in case they define "color" instead of "colorize"
								_endMatrix = colorize(_endMatrix, this.vars.color, this.vars.amount);
							}
							var ndl:Number = this.delay - ((getTimer() - this.initTime) / 1000); //new delay. We need this because reversed (TweenLite.from() calls) need to maintain the delay in any sub-tweens (like for color or volume tweens) but normal TweenLite.to() tweens should have no delay because this function gets called only when the begin!
							_clrMtxTw = new TweenLite(_matrix, this.duration, {endArray:_endMatrix, ease:this.vars.ease, delay:ndl, overwrite:false, runBackwards:this.vars.runBackwards});
							_clrMtxTw.endTarget = _mc;
							break;
						case "shadow":
						case "dropshadow":
							setFilter(DropShadowFilter, ["alpha", "angle", "blurX", "blurY", "color", "distance", "quality", "strength", "inner", "knockout", "hideObject"], new DropShadowFilter(0, 45, 0x000000, 0, 0, 0, 1, this.vars.quality, this.vars.inner, this.vars.knockout, this.vars.hideObject));
							break;
						case "bevel":
							setFilter(BevelFilter, ["angle", "blurX", "blurY", "distance", "highlightAlpha", "highlightColor", "quality", "shadowAlpha", "shadowColor", "strength"], new BevelFilter(0, 0, 0xFFFFFF, 0.5, 0x000000, 0.5, 2, 2, 0, this.vars.quality));
							break;
					}
					if (this.vars.runBackwards == true) {
						flipFilterVals();
					}
				}
			}
		}
		
		private function setFilter($filterType:Class, $props:Array, $defaultFilter:BitmapFilter):void {
			_fType = $filterType;
			var fltrs:Array = _mc.filters;
			var i:int, valChange:Number;
			for (i = 0; i < fltrs.length; i++) {
				if (fltrs[i] is $filterType) {
					_f = fltrs[i];
					break;
				}
			}
			if (_f == null) {
				fltrs.push($defaultFilter);
				_mc.filters = fltrs;
				_f = $defaultFilter;
			}
			var prop:String, tween:Object;
			for (i = 0; i < $props.length; i++) {
				prop = $props[i];
				if (this.tweens[prop] != undefined) {
					tween = this.tweens[prop];
					delete this.tweens[prop];
				} else if (this.extraTweens[prop] != undefined) {
					tween = this.extraTweens[prop];
				} else {
					tween = null;
				}
				if (tween != null) {
					if (prop == "brightness" || prop == "colorize" || prop == "amount" || prop == "saturation" || prop == "contrast" || prop == "hue" || prop == "threshold") { 
						
					} else if (prop == "color" || prop == "highlightColor" || prop == "shadowColor") {
						var start_obj:Object = HEXtoRGB(_f[prop]);
						var end_obj:Object = HEXtoRGB(this.vars[prop]);
						_clrsa.push({p:prop, e:this.vars.ease, sr:start_obj.rb, cr:end_obj.rb - start_obj.rb, sg:start_obj.gb, cg:end_obj.gb - start_obj.gb, sb:start_obj.bb, cb:end_obj.bb - start_obj.bb});
					} else if (prop == "quality" || prop == "inner" || prop == "knockout" || prop == "hideObject") {
						_f[prop] = this.vars[prop];
					} else {
						if (typeof(this.vars[prop]) == "number") {
							valChange = this.vars[prop] - _f[prop];
						} else {
							valChange = Number(this.vars[prop]);
						}
						this.tweens[prop] = {o:_f, p:prop, s:_f[prop], c:valChange, e:this.vars.ease};
					}
				}
			}
		}
		
		private function flipFilterVals():void {
			var act:Boolean = this.active;
			var i:int, tp:Object;
			for (var p:String in this.tweens) {
				if (this.tweens[p].flipped != true) {
					tp = this.tweens[p];
					tp.s += tp.c;
					tp.c *= -1;
					tp.o[p] = tp.s;
					tp.flipped = true;
				}
			}
			for (i = 0; i < _clrsa.length; i++) {
				tp = _clrsa[i];
				tp.sr += tp.cr;
				tp.cr *= -1;
				tp.sg += tp.cg;
				tp.cg *= -1;
				tp.sb += tp.cb;
				tp.cb *= -1;
				if (!act) {
					_f[tp.p] = (tp.sr << 16 | tp.sg << 8 | tp.sb); //Translates RGB to HEX
				}
			}
			if (act && this.duration != 0.001) { //If the duration was originally 0, we reset it to 0.001 in the TweenLite constructor to avoid problems with easing equations.
				render(getTimer());
			} else if (_mc.parent != null && _fType != null) {
				if (_endMatrix != null) {
					ColorMatrixFilter(_f).matrix = _matrix;
				}
				var nf:Array = _mc.filters.slice();
				for (i = nf.length - 1; i > -1; i--) {
					if (nf[i] is _fType) {
						nf[i] = _f;
						break;
					}
				}
				_mc.filters = nf;
			}
			if (this.vars.onUpdate != null) {
				this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
			}
		}
	
		override public function render($t:uint):void {
			var time:Number = ($t - this.startTime) / 1000;
			if (time > this.duration) {
				time = this.duration;
			}
			var factor:Number = this.vars.ease(time, 0, 1, this.duration);
			var tp:Object; 
			for (var p:String in this.tweens) {
				tp = this.tweens[p];
				tp.o[p] = tp.s + (factor * tp.c);
			}
			
			if (_mc.parent != null) { //Protects against scenarios where the _mc has been removed or isn't in the display list (in which case a 1010 error would get thrown)
				var i:int, r:Number, g:Number, b:Number;
				for (i = 0; i < _clrsa.length; i++) {
					tp = _clrsa[i];
					r = tp.sr + (factor * tp.cr);
					g = tp.sg + (factor * tp.cg);
					b = tp.sb + (factor * tp.cb);
					_f[tp.p] = (r << 16 | g << 8 | b); //Translates RGB to HEX
				}
				if (_endMatrix != null) {
					ColorMatrixFilter(_f).matrix = _matrix;
				}
				var nf:Array = _mc.filters.slice();
				for (i = nf.length - 1; i > -1; i--) {
					if (nf[i] is _fType) {
						nf[i] = _f;
						break;
					}
				}
				_mc.filters = nf;
			}
			
			if (this.vars.onUpdate != null) {
				this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
			}
			if (time == this.duration) { //Check to see if we're done
				super.complete(true);
			}
		}
		
		public function HEXtoRGB($n:Number):Object {
			return {rb:$n >> 16, gb:($n >> 8) & 0xff, bb:$n & 0xff};
		}
		
//---- COLOR MATRIX FILTER FUNCTIONS -----------------------------------------------------------------------------------------------------------------------
		
		public static function colorize($m:Array, $color:Number, $amount:Number = 100):Array { //You can use 
			if (isNaN($color)) {
				return $m;
			} else if (isNaN($amount)) {
				$amount = 1;
			}
			var r:Number = (($color >> 16) & 0xff) / 255;
			var g:Number = (($color >> 8)  & 0xff) / 255;
			var b:Number = ($color         & 0xff) / 255;
			var inv:Number = 1 - $amount;
			var temp:Array =  [inv + $amount * r * _lumR, $amount * r * _lumG,       $amount * r * _lumB,       0, 0,
							  $amount * g * _lumR,        inv + $amount * g * _lumG, $amount * g * _lumB,       0, 0,
							  $amount * b * _lumR,        $amount * b * _lumG,       inv + $amount * b * _lumB, 0, 0,
							  0, 				         0, 					   0, 					     1, 0];		
			return applyMatrix(temp, $m);
		}
		
		public static function setThreshold($m:Array, $n:Number):Array {
			if (isNaN($n)) {
				return $m;
			}
			var temp:Array = [_lumR * 256, _lumG * 256, _lumB * 256, 0,  -256 * $n, 
						_lumR * 256, _lumG * 256, _lumB * 256, 0,  -256 * $n, 
						_lumR * 256, _lumG * 256, _lumB * 256, 0,  -256 * $n, 
						0,           0,           0,           1,  0]; 
			return applyMatrix(temp, $m);
		}
		
		public static function setHue($m:Array, $n:Number):Array {
			if (isNaN($n)) {
				return $m;
			}
			$n *= Math.PI / 180;
			var c:Number = Math.cos($n);
			var s:Number = Math.sin($n);
			var temp:Array = [(_lumR + (c * (1 - _lumR))) + (s * (-_lumR)), (_lumG + (c * (-_lumG))) + (s * (-_lumG)), (_lumB + (c * (-_lumB))) + (s * (1 - _lumB)), 0, 0, (_lumR + (c * (-_lumR))) + (s * 0.143), (_lumG + (c * (1 - _lumG))) + (s * 0.14), (_lumB + (c * (-_lumB))) + (s * -0.283), 0, 0, (_lumR + (c * (-_lumR))) + (s * (-(1 - _lumR))), (_lumG + (c * (-_lumG))) + (s * _lumG), (_lumB + (c * (1 - _lumB))) + (s * _lumB), 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
			return applyMatrix(temp, $m);
		}
		
		public static function setBrightness($m:Array, $n:Number):Array {
			if (isNaN($n)) {
				return $m;
			}
			$n = ($n * 100) - 100;
			return applyMatrix([1,0,0,0,$n,
								0,1,0,0,$n,
								0,0,1,0,$n,
								0,0,0,1,0,
								0,0,0,0,1], $m);
		}
		
		public static function setSaturation($m:Array, $n:Number):Array {
			if (isNaN($n)) {
				return $m;
			}
			var inv:Number = 1 - $n;
			var r:Number = inv * _lumR;
			var g:Number = inv * _lumG;
			var b:Number = inv * _lumB;
			var temp:Array = [r + $n, g     , b     , 0, 0,
							  r     , g + $n, b     , 0, 0,
							  r     , g     , b + $n, 0, 0,
							  0     , 0     , 0     , 1, 0];
			return applyMatrix(temp, $m);
		}
		
		public static function setContrast($m:Array, $n:Number):Array {
			if (isNaN($n)) {
				return $m;
			}
			$n += 0.01;
			var temp:Array =  [$n,0,0,0,128 * (1 - $n),
							   0,$n,0,0,128 * (1 - $n),
							   0,0,$n,0,128 * (1 - $n),
							   0,0,0,1,0];
			return applyMatrix(temp, $m);
		}
		
		public static function applyMatrix($m:Array, $m2:Array):Array {
			if (!($m is Array) || !($m2 is Array)) {
				return $m2;
			}
			var temp:Array = [];
			var i:int = 0;
			var z:int = 0;
			var y:int, x:int;
			for (y = 0; y < 4; y++) {
				for (x = 0; x < 5; x++) {
					if (x == 4) {
						z = $m[i + 4];
					} else {
						z = 0;
					}
					temp[i + x] = $m[i]   * $m2[x]      + 
								  $m[i+1] * $m2[x + 5]  + 
								  $m[i+2] * $m2[x + 10] + 
								  $m[i+3] * $m2[x + 15] +
								  z;
				}
				i += 5;
			}
			return temp;
		}
	}
}