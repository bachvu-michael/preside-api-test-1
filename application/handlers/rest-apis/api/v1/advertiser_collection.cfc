/**
 * @restUri /advertisers/
 */
component {

    property name="dao" inject="presidecms:object:advertiser";

    /**
     * @hint This endpoint returns advertisers
     * @maxRows.hint the maximum number of rows to return - 0 means return all
     * @startRow.hint the row to start with (first record to return)
     * @swagger_tags Advertisers
     * @swagger_summary Advertiser Collection
     * @swagger_responses 200:advertiser collection
     * @maxRows.swagger_type integer
     * @startRow.swagger_type integer
     */
    private void function get( numeric maxRows=0, numeric startRow=1 ) {
        
        var result = dao.selectData( maxRows=arguments.maxRows, startRow=arguments.startRow );

        restResponse.setData( queryToArray( result ) );
    }
}