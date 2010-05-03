package eu.stefaner.elasticlists.ui.facetboxes.elasticlist {
	import eu.stefaner.elasticlists.ui.facetboxes.FacetBoxElement;

	/**
	 * @author mo
	 */
	public class BarChartElasticListBox extends ElasticListBox {

		override protected function getNewFacetBoxElement() : FacetBoxElement {
			return new BarChartElasticListEntry();
		};
		
	}
}
