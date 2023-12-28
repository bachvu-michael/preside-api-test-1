component {

    private void function read( required uuid id, required any restResponse ) {

        var result = dao.selectData( id=arguments.id );

        if ( IsEmpty( result ) ) {
            arguments.restResponse.noData().setStatus( 404 );
            return;
        }
        
        arguments.restResponse.setData( queryRowData( result, 1 ) );
    }

    private void function readAll( numeric maxRows=0, numeric startRow=1, required any restResponse ) {

        var result = dao.selectData( maxRows=arguments.maxRows, startRow=arguments.startRow );

        arguments.restResponse.setData( queryToArray( result ) );
    }
}