/**
 * @restUri /advertiser/create/
 */
component {

    property name="dao" inject="presidecms:object:advertiser";
    
    /**
     * @restVerb post
     * @hint This endpoint create a single advertiser
     * @swagger_tags Advertisers
     * @swagger_summary Advertiser Create
     * @swagger_responses 200:single advertiser;404:advertiser not found
     */
    private void function post() {

        if( !StructKeyExists(rc,"first_name") || !StructKeyExists(rc,"last_name") || !StructKeyExists(rc,"url") || !StructKeyExists(rc,"category") ){
            restResponse.noData().setStatus( 404 , "please fill all the fields");
            return;
        }

        var data = {
            first_name = rc.first_name,
            last_name = rc.last_name,
            url = rc.url,
            category = rc.category
        };

        var resultId = dao.insertData( data );

        var result = dao.selectData( id=resultId );

        if ( IsEmpty( result ) ) {
            restResponse.noData().setStatus( 500 ,"something went wrong");
            return;
        }

        restResponse.setData( queryRowData( result, 1 ) );
    }

}