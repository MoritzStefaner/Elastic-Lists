 /*
   
  Copyright 2010, Moritz Stefaner

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
*/

package eu.stefaner.elasticlists.data { 	/**	 * 	FacetValue 	 * 	 *	A value in a facet, which can be used for filtering	 *	 *	@langversion ActionScript 3.0	 *	@playerversion Flash 9.0	 *	 *	@author moritz@stefaner.eu	 */	public class FacetValue extends DataItem {		//	PRIVATE PROPERTIES:		public var label : String;		public var name : String;		public var totalNumContentItems : int = 0;		public var numContentItems : int = 0;		public var localRatio : Number = 0;		public var globalRatio : Number = 0;		public var globalPercentage : Number = 0;		public var localPercentage : Number = 0;		public var distinctiveness : Number = 0;

		//	CONSTRUCTOR:		public function FacetValue(name : String = "", label : String = "") : void {			super();			this.name = name;			this.label = (label != "") ? label : name;		}		//---------------------------------------		// GETTER / SETTERS		//---------------------------------------		override public function toString() : String {			return "[Object FacetValue  label:" + label + " name:" + name + "]";		};	}}