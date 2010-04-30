/**
 * MapProvider for a WMS server, in either EPSG:4326 or EPSG:900913
 */
package com.modestmaps.mapproviders
{ 
    import com.modestmaps.core.Coordinate;
    import com.modestmaps.geo.LinearProjection;
    import com.modestmaps.geo.Location;
    import com.modestmaps.geo.Transformation;
    
    import flash.net.URLVariables;
    
    public class WMSMapProvider
        extends AbstractMapProvider
        implements IMapProvider
    {
        
        public static const EPSG_4326:String = "EPSG:4326";
        public static const EPSG_900913:String = "EPSG:900913";

        public static const DEFAULT_PARAMS:Object = {
            LAYERS: '0,1',
            FORMAT: 'image/png',
            VERSION: '1.1.1',
            SERVICE: 'WMS',
            REQUEST: 'GetMap',
            SRS: 'EPSG:4326',
            WIDTH: '256',
            HEIGHT: '256'
        };

        private var serverUrl:String;
        private var wms:String;                     
        
        public function WMSMapProvider(serverURL:String, wmsParams:Object=null)
        {
            super();
            
            this.serverUrl = serverURL;
            
            if (!wmsParams) wmsParams = DEFAULT_PARAMS;
            
            var data:URLVariables = new URLVariables();
            for (var param:String in wmsParams) {
                   data[param] = wmsParams[param];
               }
            this.wms = "?" + data.toString();
            
            if (wmsParams['SRS'] == EPSG_4326) {
                var t:Transformation = new Transformation(166886.05360752725, 0, 524288, 0, -166886.05360752725, 524288);
                __projection = new LinearProjection(20, t);                 
            }
            else if (wmsParams['SRS'] != EPSG_900913) {
                throw new Error("[WMSMapProvider] Only Linear and (Google-style) Mercator projections are currently supported");
            }
        }

        public function getTileUrls(coord:Coordinate):Array
        {
            var sourceCoord:Coordinate = sourceCoordinate(coord);
            var bottomLeft:Location = coordinateLocation(coord.down());
            var topRight:Location = coordinateLocation(coord.right());
            var boundingBox:String = '&BBOX=' + [ bottomLeft.lon.toFixed(5), bottomLeft.lat.toFixed(5), topRight.lon.toFixed(5), topRight.lat.toFixed(5) ].join(',')
            //trace ("boundingBox: "+serverUrl + wms + boundingBox);
            return [serverUrl + wms + boundingBox];
        }
                
        public function toString() : String
        {
            return "WMS";
        }
    }
}