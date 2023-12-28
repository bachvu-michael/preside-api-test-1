/**
 * @restUri /advertiser/{id}/
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
            restResponse.noData().setStatus( 404, "data not found" );
            return;
        }
        
        restResponse.setData( queryRowData( result, 1 ) );
    }

    
    /**
     * @restVerb post
     * @hint This endpoint create a single advertiser
     * @swagger_tags Advertisers
     * @swagger_summary Advertiser Update
     * @swagger_responses 200:single advertiser;404:advertiser not found
     */
    private void function post( required uuid id ) {

        var resultOld = dao.selectData( id=arguments.id );

        if ( IsEmpty( resultOld ) ) {
            restResponse.noData().setStatus( 404, "data not found" );
            return;
        }

        var data = {
            first_name = StructKeyExists(rc,"first_name") ? rc.first_name : resultOld.first_name,
            last_name = StructKeyExists(rc,"last_name") ? rc.last_name : resultOld.last_name,
            url = StructKeyExists(rc,"url") ? rc.url : resultOld.url,
            category = StructKeyExists(rc,"category") ? rc.category : resultOld.category,
        }

        var result = dao.updateData( id=arguments.id, data=data );
        
        restResponse.setData( result );
    }

    /**
     * @restVerb delete
     * @hint This endpoint delete a single advertiser
     * @swagger_tags Advertisers
     * @swagger_summary Advertiser Delete
     * @swagger_responses 200:single advertiser;404:advertiser not found
     */
    private void function delete(  required uuid id ) {

        var result = dao.selectData( id=arguments.id );

        if ( IsEmpty( result ) ) {
            restResponse.noData().setStatus( 404, "data not found" );
            return;
        }

        var result = dao.deleteData( id=arguments.id );
        
        restResponse.setData( result );
    }
}