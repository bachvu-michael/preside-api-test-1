/**
 * An object to provide the swagger configuration for the PresideCMS REST platform
 *
 * @singleton
 * @presideService
 */
component {

	property name="systemConfigurationService" inject="delayedInjector:systemConfigurationService";
	property name="resourceDirectories" 	   inject="presidecms:directories:handlers/rest-apis";
	property name="basePath" 				   inject="coldbox:setting:rest.path";

	// map cf param types to swagger types
	SWAGGER_TYPE_MAPPINGS = {
		  boolean = "boolean"
		, string  = "string"
		, numeric = "number"
		, date    = "string"
		, uuid    = "string"
		, any     = "string"
	};

	// use these default swagger formats in case none is defined
	DEFAULT_SWAGGER_FORMATS = {
		  number  = "float"
		, integer = "int32"
		, date    = "date-time"
	};

	VALID_SWAGGER_TYPES = [ "integer", "string", "number", "boolean" ];

	VALID_SWAGGER_TYPE_FORMATS = {
		  integer = [ "int32", "int64" ]
		, number  = [ "float", "double" ]
		, string  = [ "byte", "binary", "date", "date-time", "password" ]
	};

	public any function init() {
		return this;
	}

	public struct function getSpecification() {

		if ( !variables.keyExists( "_specification" ) ) {
			_loadSpecification();
		}

		return variables._specification;
	}

	public void function clearCachedSpecification() {
		structDelete( variables, "_specification" );
	}

// PRIVATE HELPERS
	private void function _loadSpecification() {

		_readResourceDirectories();

		var apis      = _getApis();
		var settings  = systemConfigurationService.getCategorySettings( "rest-swagger" );
		var usesHTTPS = settings.keyExists( "usesHTTPS" ) && isBoolean( settings.usesHTTPS ) && settings.usesHTTPS;
		var scheme    = usesHTTPS ? "https" : "http";

		variables._specification = {
			  "swagger": "2.0"
			, "info": {
				  "title": settings.title
		        , "version": settings.version
			  }
			, "host": settings.hostname
			, "schemes": [
				scheme
			  ]
			, "basePath": basePath
			, "produces": [
				"application/json"
			  ]
			, "paths": {}
			, "definitions": {
				"Error": {
					"description": "An unexpected error occurred while processing the request"
		        }
			}
		};

		var description       = settings.description       ?: "";
		var termsOfServiceURL = settings.termsOfServiceURL ?: "";
		var contactName       = settings.contactName       ?: "";
		var contactURL        = settings.contactURL        ?: "";
		var contactEmail      = settings.contactEmail      ?: "";

		if ( len( description ) ) {
			variables._specification[ "info" ][ "description" ] = description;
		}
		if ( len( termsOfServiceURL ) ) {
			variables._specification[ "info" ][ "termsOfService" ] = termsOfServiceURL;
		}
		if ( len( contactName ) || len( contactURL ) || len( contactEmail ) ) {
			variables._specification[ "info" ][ "contact" ] = {};
			if ( len( contactName ) ) {
				variables._specification[ "info" ][ "contact" ][ "name" ] = contactName;
			}
			if ( len( contactURL ) ) {
				variables._specification[ "info" ][ "contact" ][ "url" ] = contactURL;
			}
			if ( len( contactEmail ) ) {
				variables._specification[ "info" ][ "contact" ][ "email" ] = contactEmail;
			}
		}

		// cross referencing extension preside-ext-rest-security
		if ( $isFeatureEnabled( "restSecurity" ) ) {
			var apiKeyHeader = systemConfigurationService.getSetting(
	              category = "rest-security"
	            , setting  = "http_request_header_name"
	            , default  = ""
	        );
	        var isBasicAuthEnabled = false;
	        if ( $isFeatureEnabled( "websiteUsers" ) ) {
		        isBasicAuthEnabled = systemConfigurationService.getSetting(
		              category = "rest-security"
		            , setting  = "enable_website_user_basic_auth"
		            , default  = false
		        );
		        isBasicAuthEnabled = isBoolean( isBasicAuthEnabled ) && isBasicAuthEnabled;
	    	}
	        if ( len( apiKeyHeader ) || isBasicAuthEnabled ) {
	        	variables._specification[ "security" ] = [];
	        	variables._specification[ "securityDefinitions" ] = {};

	        	if ( len( apiKeyHeader ) ) {
	        		variables._specification[ "security" ].append( { "api_key": [] } );
	        		variables._specification[ "securityDefinitions" ][ "api_key" ] = {
						  "type": "apiKey"
						, "name": apiKeyHeader
						, "in"  : "header"
					};
	        	}

	        	if ( isBasicAuthEnabled ) {
	        		variables._specification[ "security" ].append( { "basicAuth": [] } );
	        		variables._specification[ "securityDefinitions" ][ "basicAuth" ] = {
						  "type": "basic"
						, "description": "HTTP Basic Authentication"
					};
	        	}
	        }
        }

		for ( var apiBasePath in apis ) {
			for ( var apiResource in apis[ apiBasePath ] ) {
				variables._specification[ "paths" ][ apiBasePath & apiResource.restUri ] = _getEndpointSpecification( apiResource );
			}
		}
	}

	private struct function _getEndpointSpecification( required struct apiResource ) {

		var result = {};

		for ( var verb in arguments.apiResource.verbs ) {
			result[ lCase( verb ) ] = _getEndpointMethodSpecification( arguments.apiResource, verb );
		}

		return result;
	}

	private struct function _getEndpointMethodSpecification( required struct apiResource, required string verb ) {

		var result = {};
		var md     = arguments.apiResource.metadata[ arguments.verb ];
		var tokens = arguments.apiResource.tokens;

		if ( md.keyExists( "swagger_summary" ) && len( md.swagger_summary ) ) {
			result[ "summary" ] = md.swagger_summary;
		}
		if ( md.keyExists( "hint" ) && len( md.hint ) ) {
			result[ "description" ] = md.hint;
		}

		if ( !md.parameters.isEmpty() ) {
			result[ "parameters" ] = [];
			for ( var param in md.parameters ) {
				result[ "parameters" ].append( _getEndpointMethodParameter( parameterMetadata=param, verb=arguments.verb, tokens=tokens ) );				
			}
		}

		if ( md.keyExists( "swagger_tags" ) && listLen( md.swagger_tags ) > 0) {
			result[ "tags" ] = listToArray( md.swagger_tags );
		}
		
		result[ "responses" ] = _getEndpointResponses( md );
		
		return result;
	}

	private struct function _getEndpointMethodParameter( required struct parameterMetadata, required string verb, required array tokens ) {

		var md = arguments.parameterMetadata;
		var result = {
			  "name" : md.name
			, "type" : "string"
			, "in"   : "formData"
		};

		if ( md.keyExists( "swagger_type" ) && VALID_SWAGGER_TYPES.findNoCase( md.swagger_type ) > 0 ) {
			result[ "type" ] = md.swagger_type;
		}
		else if ( md.keyExists( "type" ) && SWAGGER_TYPE_MAPPINGS.keyExists( md.type ) ) {
			result[ "type" ] = SWAGGER_TYPE_MAPPINGS[ md.type ];
		}

		if ( md.keyExists( "swagger_format" ) && VALID_SWAGGER_TYPE_FORMATS[ result.type ].findNoCase( md.swagger_format ) > 0 ) {
			result[ "format" ] = md.swagger_format;
		}

		if ( !result.keyExists( "format" ) && DEFAULT_SWAGGER_FORMATS.keyExists( result.type ) ) {
			result[ "format" ] = DEFAULT_SWAGGER_FORMATS[ result.type ];	
		}

		if ( arguments.tokens.findNoCase( md.name ) > 0 ) {
			result[ "in" ] = "path";
		}
		else if ( arguments.verb == "get" ) {
			result[ "in" ] = "query";
		}

		if ( md.keyExists( "hint" ) && len( md.hint ) ) {
			result[ "description" ] = md.hint;
		}

		if ( result.in == "path" || ( md.keyExists( "required" ) && md.required ) ) {
			result[ "required" ] = true;
		}

		if ( md.keyExists( "default" ) ) {
			result[ "default" ] = md.default;
		}

		return result;
	}

	private struct function _getEndpointResponses( required struct functionMetadata ) {

		var result = {
			"default": {
                  "description": "Unexpected error"
                , "schema": {
                    "$ref": "##/definitions/Error"
                }
            }
		};

		var md = arguments.functionMetadata;

		if ( !md.keyExists( "swagger_responses" ) || len( md.swagger_responses ) == 0) {
			return result;
		}

		// format: RESPONSE1;RESPONSE2;... (";" = delimiter)
		var responseStrings = listToArray( md.swagger_responses, ";" );
		var code 			= "";
		var responseTokens 	= 0;
		var headers 		= "";
		var headerName 		= "";

		for ( var responseString in responseStrings ) {
			// format: CODE:DESCRIPTION:HEADERS (":" = delimiter)
			// CODE = http status code
			// DESCRIPTION = optional, default="default"
			// HEADERS = optional, default={}

			// TODO: maybe support complex response models later

			responseTokens = listToArray( responseString, ":" );
			code = responseTokens[ 1 ];
			result[ code ] = {
				"description": responseTokens[ 2 ] ?: "default response"
			};

			if ( responseTokens.len() > 2 ) {
				headers = listToArray( responseTokens[ 3 ] );
				result[ code ][ "headers" ] = {};
				for ( headerName in headers ) {
					result[ code ][ "headers" ][ headerName ] = { "type": "string" };
				}
			}
		}

		return result;
	}

	private void function _readResourceDirectories() {

		var resourceReader = new preside.system.services.rest.PresideRestResourceReader();
		var apis 		   = resourceReader.readResourceDirectories( resourceDirectories );
		var dirs 		   = arrayReverse( resourceDirectories );

		// prepare a helper that holds relative/absolute/dotted root paths
		var resourcePaths = [];
		var resourcePath  = 0;

		for ( var dir in dirs ) {
			resourcePath = { relative=dir };
			resourcePath.absolute = expandPath( resourcePath.relative );
			// dot-notation required for object metadata retrieval
			resourcePath.dotted = arrayToList( listToArray( resourcePath.relative, "/" ), "." );
			resourcePaths.append( resourcePath );
		}

		var relativeResourcePath = "";
		var absoluteCfcPath 	 = "";
		var cfcDotPath 			 = "";
		var md 					 = 0;

		for ( var apiBasePath in apis ) {
			for ( var resource in apis[ apiBasePath ] ) {
				resource.metadata = {};
				relativeResourcePath = listChangeDelims( resource.handler, server.separator.file, "." );
				for ( resourcePath in resourcePaths ) {
					absoluteCfcPath = resourcePath.absolute & server.separator.file & relativeResourcePath & ".cfc";
					if ( !fileExists( absoluteCfcPath ) ) {
						continue;
					}
					cfcDotPath = resourcePath.dotted & "." & resource.handler;
					md = getComponentMetadata( cfcDotPath );
					resource.restUri = md.restUri;
					for ( var verb in resource.verbs ) {
						if ( resource.metadata.keyExists( verb ) ) {
							// we already have it from a more specific endpoint handler - the processing order matters: site, extensions, core
							continue;
						}
						for ( var fn in md.functions ) {
							if ( fn.name == resource.verbs[ verb ] ) {
								resource.metadata[ verb ] = fn;
							}
						}
					}
				}
			}
		}

		_setApis( apis );
	}

// GETTERS AND SETTERS
	private struct function _getApis() {
		return _apis;
	}
	private void function _setApis( required struct apis ) {
		_apis = arguments.apis;
	}
}