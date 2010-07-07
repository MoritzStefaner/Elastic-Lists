package eu.stefaner.elasticlists.data {

	/**
	 * @author mo
	 */
	public class FacetValueConstraint extends FilterConstraint {

		private var facetValue : FacetValue;

		public function FacetValueConstraint(facetValue:FacetValue) {
			this.facetValue = facetValue;
		}

		override public function match(c : ContentItem) : Boolean {
			return c.facetValues[facetValue];
		}
	}
}
