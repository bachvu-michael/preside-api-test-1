component {

    property name="systemConfigurationService" inject="delayedInjector:systemConfigurationService";
    property name="featureService"             inject="delayedInjector:featureService";
    property name="presideObjectService"       inject="delayedInjector:presideObjectService";
    property name="bcryptService"              inject="delayedInjector:bcryptService";
    property name="logger"                     inject="logbox:logger:restsecurity";

    public void function configure() {}

    public void function postPresideReload( event, interceptData ) {

        if ( !featureService.isFeatureEnabled( "restSecurity" ) ) {
            return;
        }

        // check if system settings are defined, otherwise set default values
        _ensureSystemSettings();

        if ( !featureService.isFeatureEnabled( "websiteUsers" ) ) {
            return;
        }

        _addMissingWebsiteUserApiKeys();
    }

    public void function onRestRequest( event, interceptData ) {

        if ( !featureService.isFeatureEnabled( "restSecurity" ) || !_isEnabled()) {
            return;
        }

        var restRequest       = arguments.interceptData.restRequest;
        var restResponse      = arguments.interceptData.restResponse;
        var httpRequestData   = getHTTPRequestData();
        var httpHeaderName    = _getAPIKeyHTTPHeaderName();
        var headers           = httpRequestData.headers;

        if ( headers.keyExists( httpHeaderName ) ) {
            _apiKeyAuth(
                  apiKey         = trim( headers[ httpHeaderName ] )
                , httpHeaderName = httpHeaderName
                , restRequest    = restRequest
                , restResponse   = restResponse
            );
            return;
            
        }

        var isWebsiteUserBasicAuthEnabled = _isWebsiteUserBasicAuthEnabled();

        if ( isWebsiteUserBasicAuthEnabled
            && headers.keyExists( "Authorization" )
            && listLen( headers.Authorization, " " ) == 2 
            && listFirst( headers.Authorization, " " ) == "Basic"
        ) {
            _basicAuth(
                  encodedCredentials = listLast( headers.Authorization, " " )
                , restRequest        = restRequest
                , restResponse       = restResponse
            );
            return;
        }

        var message = "Missing HTTP header '#httpHeaderName#'";
        if ( isWebsiteUserBasicAuthEnabled ) {
            message &= " or Basic Authorization"
        }
        _authorizationError( restRequest, restResponse, message, 401, "Not Authenticated" );
    }

// PRIVATE HELPERS
    private void function _apiKeyAuth(
          required string apiKey
        , required string httpHeaderName
        , required any    restRequest
        , required any    restResponse
    ) {
        if ( isEmpty( arguments.apiKey ) ) {
            _authorizationError( arguments.restRequest, arguments.restResponse, "Empty HTTP header '#arguments.httpHeaderName#'", 401, "Not Authenticated" );
            return;
        }

        var masterAPIKey = _getMasterAPIKey();

        if ( len( masterAPIKey ) && arguments.apiKey == masterAPIKey ) {
            // request used the defined master API key - that's fine, just continue
            return;
        }

        // check if extended API key management is enabled and the supplied key is defined
        if ( _apiKeyManagementEnabled() ) {
            var key = presideObjectService.selectData( objectName="rest_api_key", filter={ key=arguments.apiKey } );

            if ( key.recordCount ) {
                if ( key.active ) {
                    _maybeTrackApiKeyAccess( key.id, key.access_count );
                    return;
                }
                else {
                    // should we track that?
                }
            }
        }

        // check if it's a of a website user
        if ( featureService.isFeatureEnabled( "websiteUsers" ) ) {
            var websiteUser = presideObjectService.selectData( objectName="website_user", filter={ rest_api_key=arguments.apiKey } );

            if ( websiteUser.recordCount ) {
                // found a website user, but is the user has REST API access enabled?
                if ( websiteUser.rest_api_enabled ) {
                    _maybeTrackWebsiteUserAccess( websiteUser.id, websiteUser.rest_api_access_count );
                    return;
                }
                else {
                    // should we track that?
                }
            }
        }

        _authorizationError( arguments.restRequest, arguments.restResponse, "Invalid API Key. Please use a valid API key in HTTP header '#arguments.httpHeaderName#'" );
    }

    private void function _basicAuth(
          required string encodedCredentials
        , required any    restRequest
        , required any    restResponse
    ) {
        var decodedCredentials = toString( binaryDecode( arguments.encodedCredentials, "base64" ) );

        if ( listLen( decodedCredentials, ":" ) != 2 ) {
            _basicAuthError( arguments.restRequest, arguments.restResponse );
            return;
        }

        var username = listFirst( decodedCredentials, ":" );
        var password = listLast( decodedCredentials, ":" );

        if ( isEmpty( username ) || isEmpty( password ) ) {
            _basicAuthError( arguments.restRequest, arguments.restResponse, "Invalid Basic Authorization" );
            return;
        }

        var websiteUser = presideObjectService.selectData(
              objectName   = "website_user"
            , filter       = "( login_id = :login_id or email_address = :login_id ) and active = '1'"
            , filterParams = { login_id = username }
            , useCache     = false
        );

        if ( isEmpty( websiteUser ) || !websiteUser.rest_api_enabled || !_isValidPassword( password, websiteUser.password ) ) {
            _basicAuthError( arguments.restRequest, arguments.restResponse );
            return;
        }
        
        _maybeTrackWebsiteUserAccess( websiteUser.id, websiteUser.rest_api_access_count );
    }

    private void function _basicAuthError( required any restRequest, required any restResponse ) {
        _authorizationError( arguments.restRequest, arguments.restResponse, "Invalid Basic Authorization." );
    }

    private void function _authorizationError(
          required any     restRequest
        , required any     restResponse
        ,          string  message    = "Invalid authorization"
        ,          numeric statusCode = 403
        ,          string  statusText = "Not Authorized"
    ) {

        if ( logger.canError() ) {
            logger.error( "#arguments.restRequest.getVerb()# #arguments.restRequest.getURI()#: #arguments.statusCode#, #arguments.statusText#, #arguments.message#" );
        }

        arguments.restResponse.noData()
            .setStatus( arguments.statusCode, arguments.statusText )
            .setHeader( "X-ERROR-MESSAGE",  arguments.message );
        arguments.restRequest.finish();   
    }

    private string function _getMasterAPIKey() {
        return systemConfigurationService.getSetting(
              category = "rest-security"
            , setting  = "api_key"
        );
    }

    private string function _getAPIKeyHTTPHeaderName( string defaultValue="X-API-KEY" ) {
        return systemConfigurationService.getSetting(
              category = "rest-security"
            , setting  = "http_request_header_name"
            , default  = arguments.defaultValue
        );
    }

    private boolean function _isEnabled() {
        var isEnabled = systemConfigurationService.getSetting(
              category = "rest-security"
            , setting  = "enabled"
        );

        return isBoolean( isEnabled ) && isEnabled;
    }

    private boolean function _apiKeyManagementEnabled() {
        var apiKeyManagementEnabled = systemConfigurationService.getSetting(
              category = "rest-security"
            , setting  = "enable_api_key_management"
        );
        return isBoolean( apiKeyManagementEnabled ) && apiKeyManagementEnabled;
    }

    private boolean function _trackAccess() {
        var trackAccess = systemConfigurationService.getSetting(
              category = "rest-security"
            , setting  = "track_api_key_usage"
        );
        return isBoolean( trackAccess ) && trackAccess;
    }

    private boolean function _isWebsiteUserBasicAuthEnabled() {
        if ( !featureService.isFeatureEnabled( "websiteUsers" ) ) {
            return false;
        }
        var isEnabled = systemConfigurationService.getSetting(
              category = "rest-security"
            , setting  = "enable_website_user_basic_auth"
        );

        return isBoolean( isEnabled ) && isEnabled;
    }

    private boolean function _isValidPassword( required string plainText, required string hashed ) {
        return bcryptService.checkPw( plainText=arguments.plainText, hashed=arguments.hashed );
    }

    private void function _maybeTrackApiKeyAccess( required string restApiKeyId, required any accessCount ) {
        if ( !_trackAccess() ) {
            return;
        }
        presideObjectService.updateData(
              objectName = "rest_api_key"
            , id         = arguments.restApiKeyId
            , data       = {
                  last_access  = now()
                , access_count = isNumeric( arguments.accessCount ) ? arguments.accessCount + 1 : 0
            }
        );
    }

    private void function _maybeTrackWebsiteUserAccess( required string websiteUserId, required any accessCount ) {
        if ( !_trackAccess() ) {
            return;
        }
        presideObjectService.updateData(
              objectName = "website_user"
            , id         = arguments.websiteUserId
            , data       = {
                  rest_api_last_access  = now()
                , rest_api_access_count = isNumeric( arguments.accessCount ) ? arguments.accessCount + 1 : 0
            }
        );
    }

    private void function _ensureSystemSettings() {
        
        var canInfo         = logger.canInfo();
        var httpHeaderName  = _getAPIKeyHTTPHeaderName(defaultValue="");

        if ( len( httpHeaderName ) == 0 ) {
            systemConfigurationService.saveSetting(
                  category = "rest-security"
                , setting  = "http_request_header_name"
                , value    = "X-API-KEY"
            );
            if ( canInfo ) {
                logger.info( "No HTTP request header name defined, saved default 'X-API-KEY'." );
            }
        }
    }

    private void function _addMissingWebsiteUserApiKeys() {
        var websiteUsers = presideObjectService.selectData( objectName="website_user" );
        for ( var websiteUser in websiteUsers ) {
            if ( len( websiteUser.rest_api_key ) ) {
                continue;
            }
            presideObjectService.updateData(
                  objectName = "website_user"
                , id         = websiteUser.id
                , data       = {
                      rest_api_enabled      = false
                    , rest_api_key          = hash(createUUID())
                    , rest_api_access_count = 0
                }
            );
        }
    }
}