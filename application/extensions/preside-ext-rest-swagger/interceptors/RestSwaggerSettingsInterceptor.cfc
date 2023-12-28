component {

    property name="systemConfigurationService" inject="delayedInjector:systemConfigurationService";
    property name="swaggerService"             inject="delayedInjector:swaggerService";
    property name="siteService"                inject="delayedInjector:siteService";
    property name="logger"                     inject="logbox:logger:restswagger";

    public void function configure() {}

    public void function postPresideReload( event, interceptData ) {
        
        // check if system settings are defined, otherwise set default values
        var apiTitle = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "title"
            , default  = ""
        );
        var apiVersion = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "version"
            , default  = ""
        );
        var hostname = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "hostname"
            , default  = ""
        );
        var usesHTTPS = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "usesHTTPS"
            , default  = ""
        );

        if ( len( apiTitle ) && len( apiVersion ) && len( hostname ) && len( usesHTTPS ) ) {
            return;
        }

        var canInfo     = logger.canInfo();
        var siteID      = siteService.getActiveSiteId();
        var site        = siteService.getSite( siteID );
        var appSettings = getApplicationSettings( true );

        if ( isEmpty( apiTitle ) ) {
            
            var appname = appSettings.PRESIDE_APPLICATION_ID ?: "";

            if ( isEmpty( appname ) ) {
                appname = site.name ?: "";
            }

            if ( isEmpty( appname ) ) {
                appname = "Default site";
            }

            apiTitle = appname & " REST API";

            systemConfigurationService.saveSetting(
                  category = "rest-swagger"
                , setting  = "title"
                , value  = apiTitle
            );
            if ( canInfo ) {
                logger.info( "No API title defined, using default value '#apiTitle#'." );
            }
        }

        if ( isEmpty( apiVersion ) ) {
            
            apiVersion = "0.1.0";
            
            systemConfigurationService.saveSetting(
                  category = "rest-swagger"
                , setting  = "version"
                , value  = apiVersion
            );
            if ( canInfo ) {
                logger.info( "No API Version defined, using default value #apiVersion#." );
            }
        }

        if ( isEmpty( hostname ) ) {
            
            hostname = site.domain ?: "127.0.0.1";

            var serverPort = cgi.server_port ?: 80;

            if ( serverPort != 80 ) {
                hostname &= ":" & serverPort;
            } 
            
            systemConfigurationService.saveSetting(
                  category = "rest-swagger"
                , setting  = "hostname"
                , value  = hostname
            );
            if ( canInfo ) {
                logger.info( "No API hostname defined, using default value #hostname# from defined web site." );
            }
        }

        if ( isEmpty( usesHTTPS ) ) {
            
            usesHTTPS = ( site.protocol ?: "http" ) == "https";
            
            systemConfigurationService.saveSetting(
                  category = "rest-swagger"
                , setting  = "usesHTTPS"
                , value  = usesHTTPS
            );
            if ( canInfo ) {
                logger.info( "No API usesHTTPS defined, using default value '#usesHTTPS#' from defined web site." );
            }
        }
    }

    public void function postSaveSystemConfig( event, interceptData ) {

        var category = interceptData.category ?: "";

        // hardcoded reference to preside-ext-rest-security extension as well
        if ( category == "rest-swagger" || category == "rest-security" ) {

            // clear the cached spec so it gets regenerated upon the next spec request
            swaggerService.clearCachedSpecification();
            
            if ( logger.canInfo() ) {
                logger.info( "system setting saved: cached swagger specification cleared" );
            }
        }
    }
}