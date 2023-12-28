component {

    property name="multilingualPresideObjectService" inject="delayedInjector:multilingualPresideObjectService";
    property name="featureService"                   inject="delayedInjector:featureService";
    property name="systemConfigurationService"       inject="delayedInjector:systemConfigurationService";

    public void function configure() {}

    public void function onRestRequest( event, interceptData ) {

        if ( !featureService.isFeatureEnabled( "restI18n" ) || !featureService.isFeatureEnabled( "multilingual" ) ) {
            return;
        }

        var restRequest     = arguments.interceptData.restRequest;
        var restResponse    = arguments.interceptData.restResponse;
        var languageHeaders = [];

        if ( _supportDefaultHttpHeader() ) {
            languageHeaders.append( "Accept-Language" );
        }

        var customHeader = _getCustomHttpHeader();
        
        if ( len( customHeader ) ) {
            languageHeaders.append( customHeader );
        }

        var httpRequestData = getHTTPRequestData();
        var headers         = httpRequestData.headers;

        for ( var languageHeader in languageHeaders ) {
            var languageCode = _findLanguageCodeHeader( headers, languageHeader );
            if ( _isValidLanguageCode( languageCode ) ) {
                event.setLanguage( _getLanguageID( languageCode ) );
                return;
            }
        }
    }

// PRIVATE HELPERS
    private string function _findLanguageCodeHeader( required struct headers, required string key ) {

        if ( !arguments.headers.keyExists( arguments.key ) ) {
            return "";
        }

        // deal with formats like 'en-gb', 'fr-FR', etc.
        if ( listLen( arguments.headers[ arguments.key ], "-" ) > 1 ) {
            return listFirst( arguments.headers[ arguments.key ], "-" );
        }

        return arguments.headers[ arguments.key ];
    }

    private boolean function _isValidLanguageCode( required string lang ) {
        
        if ( isEmpty( arguments.lang ) ) {
            return false;
        }

        return structKeyExists( _getLanguageMap(), arguments.lang );
    }

    private struct function _getLanguageMap() {
        
        var languageObjects = multilingualPresideObjectService.listLanguages();
        var languageIDs     = {};
        
        for ( var languageObject in languageObjects ) {
            languageIDs[ languageObject.iso_code ] = languageObject.id;
        }

        return languageIDs;
    }

    private string function _getLanguageID( required string lang ) {
        return _getLanguageMap()[ arguments.lang ];
    }

    private boolean function _supportDefaultHttpHeader() {
        var supportDefaultHeader = systemConfigurationService.getSetting(
              category = "rest-i18n"
            , setting  = "supportDefaultHeader"
            , default  = true
        );
        return isBoolean( supportDefaultHeader ) && supportDefaultHeader;
    }

    private string function _getCustomHttpHeader() {
        return systemConfigurationService.getSetting(
              category = "rest-i18n"
            , setting  = "customHeader"
            , default  = ""
        );
    }
}