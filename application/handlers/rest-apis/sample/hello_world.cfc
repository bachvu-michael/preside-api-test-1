/**
 * @restUri /hello/
 */
component {

    /**
     * @hint This endpoint returns 'Hello World'
     * @swagger_tags Sample
     * @swagger_summary Hello World
     * @swagger_responses 200:hello world
     */
    private void function get() {
        restResponse.setData( "Hello World" );
    }
}