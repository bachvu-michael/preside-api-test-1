/**
 * @restUri /advertisers/{id}/
 */
component {

    property name="dao" inject="presidecms:object:advertiser";

    /**
     * @hint This endpoint returns a single advertiser
     * @id.hint the uuid of the advertiser
     * @swagger_tags Advertisers
     * @swagger_summary Advertiser
     * @swagger_responses 200:single advertiser;404:advertiser not found
     */
    private void function get( required uuid id ) {

        var result = dao.selectData( id=arguments.id );

        if ( IsEmpty( result ) ) {
            restResponse.noData().setStatus( 404 );
            return;
        }
        
        restResponse.setData( queryRowData( result, 1 ) );
    }
}