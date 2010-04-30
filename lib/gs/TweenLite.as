/*
VERSION: 5.87
DATE: 1/8/2008
ACTIONSCRIPT VERSION: 3.0 (AS2 version is also available)
UPDATES & MORE DETAILED DOCUMENTATION AT: http://www.TweenLite.com (there's a link to the AS3 version)
DESCRIPTION:
	Tweening. We all do it. Most of us have learned to avoid Adobe's Tween class in favor of a more powerful, 
	less code-heavy engine (Tweener, Fuse, MC Tween, etc.). Each has its own strengths & weaknesses. A few years back, 
	I created TweenLite because I needed a very compact tweening engine that was fast and efficient (I couldn't 
	afford the file size bloat that came with the other tweening engines). It quickly became integral to my work flow.

	Since then, I've added new capabilities while trying to keep file size way down (2.6K). TweenFilterLite extends 
	TweenLite and adds the ability to tween filters including ColorMatrixFilter effects like saturation, contrast, 
	brightness, hue, and even colorization but it only adds about 3k to the file size. Same syntax as TweenLite. 
	There are AS2 and AS3 versions of both of the classes.

	I know what you're thinking - "if it's so 'lightweight', it's probably missing a lot of features which makes 
	me nervous about using it as my main tweening engine." It is true that it doesn't have the same feature set 
	as the other tweening engines, but I can honestly say that after using it on almost every project I've worked 
	on over the last few years, it has never let me down. I never found myself needing some other functionality. 
	You can tween any property (including a MovieClip's volume and color), use any easing function, build in delays, 
	callback functions, pass arguments to that callback function, and even tween arrays all with one line of code. 
	You very well may require a feature that TweenLite (or TweenFilterLite) doesn't have, but I think most 
	developers will use the built-in features to accomplish whatever they need and appreciate the streamlined 
	nature of the class(es).

	I haven't been able to find a faster tween engine either. The syntax is simple and the class doesn't rely on 
	complicated prototype alterations that can cause problems with certain compilers. TweenLite is simple, very 
	fast, and more lightweight than any other popular tweening engine with similar features.

ARGUMENTS:
	1) $target: Target MovieClip (or any other object) whose properties we're tweening
	2) $duration: Duration (in seconds) of the effect
	3) $vars: An object containing the end values of all the properties you'd like to have tweened (or if you're using the 
	         TweenLite.from() method, these variables would define the BEGINNING values). For example:
					  alpha: The alpha (opacity level) that the target object should finish at (or begin at if you're 
							 using TweenLite.from()). For example, if the target.alpha is 1 when this script is 
					  		 called, and you specify this argument to be 0.5, it'll transition from 1 to 0.5.
					  x: To change a MovieClip's x position, just set this to the value you'd like the MovieClip to 
					     end up at (or begin at if you're using TweenLite.from()). 
				  SPECIAL PROPERTIES (**OPTIONAL**):
				  	  delay: Amount of delay before the tween should begin (in seconds).
					  ease: You can specify a function to use for the easing with this variable. For example, 
					        fl.motion.easing.Elastic.easeOut. The Default is Regular.easeOut.
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
					  onStartParams: An array of parameters to pass the onStart function.
					  onUpdate: If you'd like to call a function every time the property values are updated (on every frame during
								the time the tween is active), pass a reference to it here.
					  onUpdateParams: An array of parameters to pass the onUpdate function (this is optional)
					  onComplete: If you'd like to call a function when the tween has finished, use this. 
					  onCompleteParams: An array of parameters to pass the onComplete function
					  overwrite: If you do NOT want the tween to automatically overwrite any other tweens that are 
					             affecting the same target, make sure this value is false.
	
	

EXAMPLES: 
	As a simple example, you could tween the alpha to 50% (0.5) and move the x position of a MovieClip named "clip_mc" 
	to 120 and fade the volume to 0 over the course of 1.5 seconds like so:
	
		import gs.TweenLite;
		TweenLite.to(clip_mc, 1.5, {alpha:0.5, x:120, volume:0});
	
	If you want to get more advanced and tween the clip_mc MovieClip over 5 seconds, changing the alpha to 0.5, 
	the x to 120 using the "easeOutBack" easing function, delay starting the whole tween by 2 seconds, and then call
	a function named "onFinishTween" when it has completed and pass in a few parameters to that function (a value of
	5 and a reference to the clip_mc), you'd do so like:
		
		import gs.TweenLite;
		import fl.motion.easing.Back;
		TweenLite.to(clip_mc, 5, {alpha:0.5, x:120, ease:Back.easeOut, delay:2, onComplete:onFinishTween, onCompleteParams:[5, clip_mc]});
		function onFinishTween(argument1:Number, argument2:MovieClip):void {
			trace("The tween has finished! argument1 = " + argument1 + ", and argument2 = " + argument2);
		}
	
	If you have a MovieClip on the stage that is already in it's end position and you just want to animate it into 
	place over 5 seconds (drop it into place by changing its y property to 100 pixels higher on the screen and 
	dropping it from there), you could:
		
		import gs.TweenLite;
		import fl.motion.easing.Elastic;
		TweenLite.from(clip_mc, 5, {y:"-100", ease:Elastic.easeOut});		
	

NOTES:
	- This class will add about 2.6kb to your Flash file.
	- Putting quotes around values will make the tween relative to the current value. For example, if you do
	  TweenLite.to(mc, 2, {x:"-20"}); it'll move the mc.x to the left 20 pixels which is the same as doing
	  TweenLite.to(mc, 2, {x:mc.x - 20});
	- You must target Flash Player 9 or later (ActionScript 3.0)
	- You can tween the volume of any MovieClip using the tween property "volume", like:
	  TweenLite.to(myClip_mc, 1.5, {volume:0});
	- You can tween the color of a MovieClip using the tween property "tint", like:
	  TweenLite.to(myClip_mc, 1.5, {tint:0xFF0000});
	- To tween an array, just pass in an array as a property named endArray like:
	  var myArray:Array = [1,2,3,4];
	  TweenLite.to(myArray, 1.5, {endArray:[10,20,30,40]});
	- You can kill all tweens for a particular object (usually a MovieClip) anytime with the 
	  TweenLite.killTweensOf(myClip_mc); function. If you want to have the tweens forced to completion, 
	  pass true as the second parameter, like TweenLite.killTweensOf(myClip_mc, true);
	- You can kill all delayedCalls to a particular function using TweenLite.killDelayedCallsTo(myFunction_func);
	  This can be helpful if you want to preempt a call.
	- Use the TweenLite.from() method to animate things into place. For example, if you have things set up on 
	  the stage in the spot where they should end up, and you just want to animate them into place, you can 
	  pass in the beginning x and/or y and/or alpha (or whatever properties you want).
	  
	  
CHANGE LOG:
	5.87:
		- Fixed potential 1010 errors when an onUpdate() calls a killTweensOf() for an object.
	5.85:
		- Fixed an issue that prevented TextField filters from being applied properly with TweenFilterLite.
	5.8:
		- Added the ability to define extra easing parameters using easeParams.
		- Changed "mcColor" to "tint" in order to make it more intuitive. Using mcColor for tweening color values is deprecated and will be removed eventually.
	5.7:	
		- Improved speed (made changes to the render() and initTweenVals() functions)
		- Added a complete() function which allows you to immediately skip to the end of a tween.
	5.61:
		- Removed a line of code that in some very rare instances could contribute to an intermittent 1010 error in TweenFilterLite which extends this class.
		- Fixed an issue with tweening tint and alpha together.
	5.5: 
		- Added a few very minor conditional checks to improve reliability, and re-released with TweenFilterLite 5.5 (which fixed rare 1010 errors).
	5.4: 
		- Eliminated rare 1010 errors with TweenFilterLite
	5.3:
		- Added onUpdate and onUpdateParams features
		- Finally removed extra/duplicated (deprecated) constructor parameters that had been left in for almost a year simply for backwards compatibility.

CODED BY: Jack Doyle, jack@greensock.com
Copyright 2007, GreenSock (This work is subject to the terms in http://www.greensock.com/terms_of_use.html.)
*/

package gs {
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.geom.ColorTransform;
	import flash.utils.*;

	public class TweenLite {
		public static var version:Number = 5.87;
		public static var killDelayedCallsTo:Function = killTweensOf;
		private static var _sprite:Sprite = new Sprite(); //A reference to the sprite that we use to drive all our ENTER_FRAME events.
		private static var _listening:Boolean; //If true, the ENTER_FRAME is being listened for (there are tweens that are in the queue)
		private static var _timer:Timer = new Timer(2000);
		protected static var _all:Dictionary = new Dictionary(); //Holds references to all our tween targets.
		private var _sound:SoundTransform; //We only use this in cases where the user wants to change the volume of a MovieClip (they pass in a "volume" property in the v)
		protected var _endTarget:Object; //End target. It's almost always the same as this.target except for volume and color tweens. It helps us to see what object or MovieClip the tween really pertains to (so that we can killTweensOf() properly and hijack auto-overwritten ones)
		protected var _active:Boolean; //If true, this tween is active.
		protected var _color:ColorTransform;
		protected var _endColor:ColorTransform; 
		
		public var duration:Number; //Duration (in seconds)
		public var vars:Object; //Variables (holds things like _alpha or _y or whatever we're tweening)
		public var delay:Number; //Delay (in seconds)
		public var startTime:uint; //Start time
		public var initTime:uint; //Time of initialization. Remember, we can build in delays so this property tells us when the frame action was born, not when it actually started doing anything.
		public var tweens:Object; //Contains parsed data for each property that's being tweened (each has to have a target, property, start, a change, and an ease).
		public var extraTweens:Object; //If we run into a property that's supposed to be tweening but the target has no such property, those tweens get dumped in here.
		public var target:Object; //Target object (often a MovieClip)
		
		public function TweenLite($target:Object, $duration:Number, $vars:Object) {
			if ($target == null) {return};
			if (($vars.overwrite != false && $target != null) || _all[$target] == undefined) { 
				delete _all[$target];
				_all[$target] = new Dictionary();
			}
			_all[$target][this] = this;
			this.vars = $vars;
			this.duration = $duration;
			this.delay = $vars.delay || 0;
			if ($duration == 0) {
				this.duration = 0.001; //Easing equations don't work when the duration is zero.
				if (this.delay == 0) {
					this.vars.runBackwards = true; //The simplest (most lightweight) way to force an immediate render of the target values
				}
			}
			this.target = _endTarget = $target;
			if (!(this.vars.ease is Function)) {
				this.vars.ease = easeOut;
			}
			if (this.vars.easeParams != null) {
				this.vars.proxiedEase = this.vars.ease;
				this.vars.ease = easeProxy;
			}
			if (this.vars.mcColor != null) {
				this.vars.tint = this.vars.mcColor;
			}
			if (!isNaN(Number(this.vars.autoAlpha))) {
				this.vars.alpha = Number(this.vars.autoAlpha);
			}
			this.tweens = {};
			this.extraTweens = {};
			this.initTime = getTimer();
			if (this.vars.runBackwards == true) {
				initTweenVals();
			}
			_active = false;
			if ($duration == 0 && this.delay == 0) {
				complete(true);
			} else if (!_listening) {
				_sprite.addEventListener(Event.ENTER_FRAME, executeAll);
				_timer.addEventListener("timer", killGarbage);
            	_timer.start();
				_listening = true;
			}
		}
		
		public function initTweenVals():void {
			var ndl:Number = this.delay - ((getTimer() - this.initTime) / 1000); //new delay. We need this because reversed (TweenLite.from() calls) need to maintain the delay in any sub-tweens (like for color or volume tweens) but normal TweenLite.to() tweens should have no delay because this function gets called only when the begin!
			var p:String, valChange:Number; //For looping (for p in this.vars)
			if (this.target is Array) {
				var endArray:Array = this.vars.endArray || [];
				for (var i:int = 0; i < endArray.length; i++) {
					if (this.target[i] != endArray[i] && this.target[i] != undefined) {
						this.tweens[i.toString()] = {o:this.target, s:this.target[i], c:endArray[i] - this.target[i]}; //o: object, s:starting value, c:change in value, e: easing function
					}
				}
			} else {
				for (p in this.vars) {
					if (p == "delay" || p == "ease" || p == "overwrite" || p == "onComplete" || p == "onCompleteParams" || p == "runBackwards" || p == "onUpdate" || p == "onUpdateParams" || p == "autoAlpha" || p == "onStart" || p == "onStartParams" || p == "easeParams" || p == "mcColor" || p == "type") { //"type" is for TweenFilterLite, and it's an issue when trying to tween filters on TextFields which do actually have a "type" property.
						
					} else if (p == "tint" && this.target is DisplayObject) { //If we're trying to change the color of a DisplayObject, then set up a quasai proxy using an instance of a TweenLite to control the color.
						_color = this.target.transform.colorTransform;
						_endColor = new ColorTransform();
						if (this.vars.alpha != undefined) {
							_endColor.alphaMultiplier = this.vars.alpha;
							delete this.vars.alpha;
							delete this.tweens.alpha;
						} else {
							_endColor.alphaMultiplier = this.target.alpha;
						}
						if (this.vars[p] != null && this.vars[p] != "") { //In case they're actually trying to remove the colorization, they should pass in null or "" for the tint
							_endColor.color = this.vars[p];
						}
						var colorTween:TweenLite = new TweenLite(this, this.duration, {colorProxy:1, delay:ndl, overwrite:false, ease:this.vars.ease, runBackwards:this.vars.runBackwards});
						colorTween.endTarget = this.target;
					} else if (p == "volume" && this.target is MovieClip) { //If we're trying to change the volume of a MovieClip, then set up a quasai proxy using an instance of a TweenLite to control the volume.
						_sound = this.target.soundTransform;
						var volTween:TweenLite = new TweenLite(this, this.duration, {volumeProxy:this.vars[p], ease:easeOut, delay:ndl, overwrite:false, runBackwards:this.vars.runBackwards});
						volTween.endTarget = this.target;
					} else {
						if (this.target.hasOwnProperty(p)) {
							if (typeof(this.vars[p]) == "number") {
								valChange = this.vars[p] - this.target[p];
							} else {
								valChange = Number(this.vars[p]);
							}
							this.tweens[p] = {o:this.target, s:this.target[p], c:valChange}; //o: object, p:property, s:starting value, c:change in value, e: easing function
						} else {
							this.extraTweens[p] = {o:this.target, s:0, c:0, v:this.vars[p]}; //classes that extend this one (like TweenFilterLite) may need it (like for blurX, blurY, and other filter properties)
						}
					}
				}
			}
			if (this.vars.runBackwards == true) {
				var tp:Object;
				for (p in this.tweens) {
					tp = this.tweens[p];
					tp.s += tp.c;
					tp.c *= -1;
					tp.o[p] = tp.s;
				}
				if (this.vars.onUpdate != null) {
					this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
				}
			}
			if (typeof(this.vars.autoAlpha) == "number") {
				this.target.visible = !(this.vars.runBackwards == true && this.target.alpha == 0);
			}
		}
		
		public static function to($target:Object, $duration:Number, $vars:Object):TweenLite {
			return new TweenLite($target, $duration, $vars);
		}
		
		//This function really helps if there are objects (usually MovieClips) that we just want to animate into place (they are already at their end position on the stage for example). 
		public static function from($target:Object, $duration:Number, $vars:Object):TweenLite {
			$vars.runBackwards = true;
			return new TweenLite($target, $duration, $vars);
		}
		
		public static function delayedCall($delay:Number, $onComplete:Function, $onCompleteParams:Array = null):TweenLite {
			return new TweenLite($onComplete, 0, {delay:$delay, onComplete:$onComplete, onCompleteParams:$onCompleteParams, overwrite:false}); //NOTE / TO-DO: There may be a bug in the Dictionary class that causes it not to handle references to objects correctly! (I haven't verified this yet)
		}
		
		public static function removeTween($t:TweenLite = null):void {
			if ($t != null && _all[$t.endTarget] != undefined) {
				delete _all[$t.endTarget][$t];
			}
		}
		
		public static function killTweensOf($tg:Object = null, $complete:Boolean = false):void {
			if ($tg != null && _all[$tg] != undefined) {
				if ($complete) {
					var o:Object = _all[$tg];
					for (var tw:* in o) {
						o[tw].complete(false);
					}
				}
				delete _all[$tg];
			}
		}
		
		public function render($t:uint):void {
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
			if (this.vars.onUpdate != null) {
				this.vars.onUpdate.apply(null, this.vars.onUpdateParams);
			}
			if (time == this.duration) { //Check to see if we're done
				complete(true);
			}
		}
		
		public static function executeAll($e:Event):void {
			var a:Object = _all;
			var t:uint = getTimer();
			var p:Object, tw:Object;
			for (p in a) {
				for (tw in a[p]) {
					if (a[p][tw] != undefined && a[p][tw].active) {
						a[p][tw].render(t);
						if (a[p] == undefined) { //Could happen if, for example, an onUpdate triggered a killTweensOf() for the object that's currently looping here. Without this code, we run the risk of hitting 1010 errors
							break;
						}
					}
				}
			}
		}
		
		public function complete($skipRender:Boolean = false):void {
			if (!$skipRender) {
				this.startTime = 0;
				render(this.duration * 1000); //Just to force the render
				return;
			}
			if (typeof(this.vars.autoAlpha) == "number" && this.target.alpha == 0) { 
				this.target.visible = false;
			}
			if (this.vars.onComplete != null) {
				this.vars.onComplete.apply(null, this.vars.onCompleteParams);
			}
			removeTween(this);
		}
		
		public static function killGarbage($e:TimerEvent):void {
			var a:Object = _all;
			var tg_cnt:uint = 0;
			var found:Boolean;
			var p:Object, twp:Object, tw:Object;
			for (p in a) {
				found = false;
				for (twp in a[p]) {
					found = true;
					break;
				}
				if (!found) {
					delete a[p];
				} else {
					tg_cnt++;
				}
			}
			if (tg_cnt == 0) {
				_sprite.removeEventListener(Event.ENTER_FRAME, executeAll);
				_timer.removeEventListener("timer", killGarbage);
				_timer.stop();
				_listening = false;
			}
		}
		
		//Default ease function for tweens other than alpha (Regular.easeOut)
		protected static function easeOut($t:Number, $b:Number, $c:Number, $d:Number):Number {
			return -$c * ($t /= $d) * ($t - 2) + $b;
		}
		
		protected function easeProxy($t:Number, $b:Number, $c:Number, $d:Number):Number { //Just for when easeParams are passed in via the vars object.
			return this.vars.proxiedEase.apply(null, arguments.concat(this.vars.easeParams));
		}
		
//---- GETTERS / SETTERS -----------------------------------------------------------------------
		
		public function get active():Boolean {
			if (_active) {
				return true;
			} else if ((getTimer() - this.initTime) / 1000 > this.delay) {
				_active = true;
				this.startTime = this.initTime + (this.delay * 1000);
				if (this.vars.runBackwards != true) {
					initTweenVals();
				} else if (typeof(this.vars.autoAlpha) == "number") {
					this.target.visible = true;
				}
				if (this.vars.onStart != null) {
					this.vars.onStart.apply(null, this.vars.onStartParams);
				}
				if (this.duration == 0.001) { //In the constructor, if the duration is zero, we shift it to 0.001 because the easing functions won't work otherwise. We need to offset the this.startTime to compensate too.
					this.startTime -= 1;
				}
				return true;
			} else {
				return false;
			}
		}
		public function set endTarget($t:Object):void {
			if (this.duration == 0.001 && this.delay <= 0) { //Otherwise subtweens (like for color or volume) that have a duration of 0 will stick around for 1 frame and get rendered in the executeAll() loop which means they'll render incorrectly
				removeTween(this);
			} else {
				delete _all[_endTarget][this];
				_endTarget = $t;
				if (_all[$t] == undefined) {
					_all[$t] = new Dictionary();
				}
				_all[$t][this] = this;
			}
		}
		public function get endTarget():Object {
			return _endTarget;
		}
		public function set volumeProxy($n:Number):void { //Used as a proxy of sorts to control the volume of the target MovieClip.
			_sound.volume = $n;
			this.target.soundTransform = _sound;
		}
		public function get volumeProxy():Number {
			return _sound.volume;
		}
		public function set colorProxy($n:Number):void { 
			var r:Number = 1 - $n;
			this.target.transform.colorTransform = new ColorTransform(_color.redMultiplier * r + _endColor.redMultiplier * $n,
																	  _color.greenMultiplier * r + _endColor.greenMultiplier * $n,
																	  _color.blueMultiplier * r + _endColor.blueMultiplier * $n,
																	  _color.alphaMultiplier * r + _endColor.alphaMultiplier * $n,
																	  _color.redOffset * r + _endColor.redOffset * $n,
																	  _color.greenOffset * r + _endColor.greenOffset * $n,
																	  _color.blueOffset * r + _endColor.blueOffset * $n,
																	  _color.alphaOffset * r + _endColor.alphaOffset * $n);
		}
		public function get colorProxy():Number {
			return 0;
		}
		/* If you want to be able to set or get the progress of a Tween, uncomment these getters/setters. 0 = beginning, 0.5 = halfway through, and 1 = complete
		public function get progress():Number {
			return ((getTimer() - this.startTime) / 1000) / this.duration || 0;
		}
		public function set progress($n:Number):void {
			var tmr:int = getTimer();
			var t:Number = tmr - ((this.duration * $n) * 1000);
			this.initTime = t - (this.delay * 1000);
			var s:Boolean = this.active; //Just to trigger all the onStart stuff.
			this.startTime = t;
			render(tmr);
		}
		*/
	}
	
}