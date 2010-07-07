package eu.stefaner.elasticlists.data {
	import com.modestmaps.core.MapExtent;

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

			for each(var f:FilterConstraint in values) {
				if(conjunctive) {
					if(!f.match(c)) return false;
				} else if(f.match(c)) {
					return true;
				}
			}

			return conjunctive;
		};

		public function clear() : void {
			values = [];
		}

		public function add(facetValue : FacetValue) : void {
			values.push(new FacetValueConstraint(facetValue));
		}

		public function addGeoContraint(facet : GeoFacet, filterExtent : MapExtent) : void {
			values.push(new GeoConstraint(facet, filterExtent));
		}

		public function get active() : Boolean {
			return values.length > 0;		}

		public function clearGeoContraints() : void {
			for (var i : int = 0;i < values.length;i++) {
				if(values[i] is GeoConstraint) {
					values.splice(i, 1);
					i--;
				}
			}
		}
	}
}
