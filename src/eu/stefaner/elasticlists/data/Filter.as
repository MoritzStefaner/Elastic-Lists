package eu.stefaner.elasticlists.data {

	/**
	 * @author mo
	 */
	public class Filter {

		public var values : Array = [];

		public function Filter() {
		}

		public function match(c : ContentItem) : Boolean {
			if(!active) {
				return true;
			}

			for each(var facetValue:FacetValue in values) {
				if(Model.ANDselectionWithinFacets && !c.facetValues[facetValue]) {
					return false;
				} else if(!Model.ANDselectionWithinFacets && c.facetValues[facetValue]) {
					return true;
				}
			}

			return Model.ANDselectionWithinFacets;
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
