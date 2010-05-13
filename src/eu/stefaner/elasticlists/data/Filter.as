package eu.stefaner.elasticlists.data {

	/**
	 * @author mo
	 */
	public class Filter {

		public var values : Array = [];
		public var conjunctive : Boolean = Model.ANDselectionWithinFacets;

		public function Filter() {
		}

		public function match(c : ContentItem) : Boolean {
			if(!active) {
				return true;
			}

			for each(var facetValue:FacetValue in values) {
				if(conjunctive && !c.facetValues[facetValue]) {
					return false;
				} else if(!conjunctive && c.facetValues[facetValue]) {
					return true;
				}
			}

			return conjunctive;
		};

		public function clear() : void {
			values = [];
		}

		public function add(facetValue : FacetValue) : void {
			values.push(facetValue);
		}

		public function get active() : Boolean {
			return values.length > 0;		}
	}
}
