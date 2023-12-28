component {

    property name="swaggerService"             inject="swaggerService";
    property name="systemConfigurationService" inject="systemConfigurationService";
    property name="environment"                inject="coldbox:setting:environment";

    function index( event, rc, prc ) {

        if ( !isFeatureEnabled( "restSwagger" ) ) {
            event.notFound();
        }

        event.renderData( type="json", data=swaggerService.getSpecification() );
    }

    function ui( event, rc, prc ) {

        if ( !isFeatureEnabled( "restSwagger" ) || !_isSwaggerUiEnabled() ) {
            event.notFound();
        }

        prc.swaggerSpecURL = _getSpecUrl();
        prc.isRestSecurityEnabled = isFeatureEnabled( "restSecurity" );

        // do this only in dev mode and if the preside-ext-rest-security extension is available
        if ( prc.isRestSecurityEnabled && environment == "local" ) {
            prc.apitoken = systemConfigurationService.getSetting(
                  category = "rest-security"
                , setting  = "api_key"
                , default  = ""
            );
        }

        return renderView( view="/swagger/ui", args=arguments );
    }

    private boolean function _isSwaggerUiEnabled() {
        var isSwaggerUiEnabled = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "enableSwaggerUi"
            , default  = true
        );

        return isBoolean( isSwaggerUiEnabled ) && isSwaggerUiEnabled;
    }

    private boolean function _usesHttps() {
        var usesHttps = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "usesHTTPS"
            , default  = true
        );

        return isBoolean( usesHttps ) && usesHttps;
    }

    private string function _getSpecUrl() {
        var usesHttps = _usesHttps();
        var result = usesHttps ? "https://" : "http://";

        var configuredHostname = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "hostname"
            , default  = ""
        );

        if ( len( configuredHostname ) ) {
            return result &= configuredHostname & "/swagger";
        }

        result &= cgi.server_name & ":";
        result &= usesHttps ? cgi.server_port_secure : cgi.server_port;

        return result & "/swagger";
    }
}