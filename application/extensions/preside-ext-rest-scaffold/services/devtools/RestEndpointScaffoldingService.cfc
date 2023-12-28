/**
 * @singleton
 */
component extends="preside.system.services.devtools.ScaffoldingService" {

// CONSTRUCTOR
    /**
     * @widgetsService.inject        WidgetsService
     * @pageTypesService.inject      PageTypesService
     * @presideObjectService.inject  PresideObjectService
     * @resourceBundleService.inject resourceBundleService
     * @appMapping.inject            coldbox:setting:appMapping
     */
    public any function init(
          required any    widgetsService
        , required any    pageTypesService
        , required any    presideObjectService
        , required any    resourceBundleService
        , required string appMapping
    ) {
        _setWidgetsService( arguments.widgetsService );
        _setPageTypesService( arguments.pageTypesService );
        _setPresideObjectService( arguments.presideObjectService );
        _setResourceBundleService( arguments.resourceBundleService );
        _setAppMapping( arguments.appMapping );

        return this;
    }

// PUBLIC API METHODS
    public array function scaffoldRestEndpoint(
          required string objectName
        , required string apiPath
        , string uri = ""
        , boolean createSwaggerAnnotations = true
        , string extension = ""
    ) {

        if ( !_getPresideObjectService().objectExists( arguments.objectName ) ) {
            throw( type="scaffoldRestEndpoint.object.notexists", message="The '#arguments.objectName#' object does not exist" );
        }

        var filesCreated = _ensureExtensionExists( arguments.extension );

        arguments.objectName = Trim( arguments.objectName );
        arguments.uri        = Trim( arguments.uri );
        arguments.apiPath    = Trim( arguments.apiPath );

        if ( IsEmpty( arguments.uri ) ) {
            arguments.uri = lCase( arguments.objectName );
        }

        arguments.uri     = _ensureLeadingSlash( _ensureTrailingSlash( arguments.uri ) );
        arguments.apiPath = _ensureLeadingSlash( _ensureTrailingSlash( arguments.apiPath ) );

        var singularObjectTitle = _getResourceBundleService().getResource( uri="preside-objects.#arguments.objectName#:title.singular", defaultValue=arguments.objectName );
        var pluralObjectTitle   = _getResourceBundleService().getResource( uri="preside-objects.#arguments.objectName#:title"         , defaultValue=arguments.objectName & "s" );
        var objectDescription   = _getResourceBundleService().getResource( uri="preside-objects.#arguments.objectName#:description"   , defaultValue=arguments.objectName );

        filesCreated.append( scaffoldRestCollectionEndpointHandler(
              objectName               = arguments.objectName
            , uri                      = arguments.uri
            , apiPath                  = arguments.apiPath
            , singularObjectTitle      = singularObjectTitle
            , pluralObjectTitle        = pluralObjectTitle
            , objectDescription        = objectDescription
            , createSwaggerAnnotations = arguments.createSwaggerAnnotations
            , extension                = arguments.extension
        ));
        filesCreated.append( scaffoldRestEndpointHandler(
              objectName               = arguments.objectName
            , uri                      = arguments.uri
            , apiPath                  = arguments.apiPath
            , singularObjectTitle      = singularObjectTitle
            , pluralObjectTitle        = pluralObjectTitle
            , objectDescription        = objectDescription
            , createSwaggerAnnotations = arguments.createSwaggerAnnotations
            , extension                = arguments.extension
        ));
        
        return filesCreated;
    }

    public string function scaffoldRestCollectionEndpointHandler(
          required string objectName
        , required string uri
        , required string apiPath
        , required string singularObjectTitle
        , required string pluralObjectTitle
        , required string objectDescription
        , required boolean createSwaggerAnnotations
        , required string extension
    ) {
        var root     = _getScaffoldRoot( arguments.extension );
        var filePath = root & "handlers/rest-apis" & arguments.apiPath & arguments.objectName & "_collection.cfc";

        if ( fileExists( filePath ) ) {
            throw( type="scaffoldPresideObject.restendpoint.exists", message="The REST endpoint for object '#arguments.objectName#' already exists ('#filePath#')" );
        }

        var swaggerAnnotations = "";

        if ( arguments.createSwaggerAnnotations ) {
            swaggerAnnotations =        "@swagger_tags #arguments.pluralObjectTitle#" & _nl()
                               & "     * @swagger_summary #arguments.singularObjectTitle# Collection" & _nl()
                               & "     * @swagger_responses 200:#lCase( arguments.singularObjectTitle )# collection" & _nl()
                               & "     * @maxRows.swagger_type integer" & _nl()
                               & "     * @startRow.swagger_type integer";
        }

        var fileContent = FileRead( ExpandPath( "/app/extensions/preside-ext-rest-scaffold/services/devtools/scaffoldingResources/restCollectionEndpoint.cfc.txt" ) );

        fileContent = Replace( fileContent, "${uri}", arguments.uri );
        fileContent = Replace( fileContent, "${objectName}", arguments.objectName );
        fileContent = Replace( fileContent, "${pluralObjectTitle}", lCase( arguments.pluralObjectTitle ) );
        fileContent = Replace( fileContent, "${swaggerAnnotations}", swaggerAnnotations );

        _ensureDirectoryExists( GetDirectoryFromPath( filePath ) );
        FileWrite( filePath, fileContent );

        return filePath;
    }

    public string function scaffoldRestEndpointHandler(
          required string objectName
        , required string uri
        , required string apiPath
        , required string singularObjectTitle
        , required string pluralObjectTitle
        , required string objectDescription
        , required boolean createSwaggerAnnotations
        , required string extension
    ) {
        var root     = _getScaffoldRoot( arguments.extension );
        var filePath = root & "handlers/rest-apis" & arguments.apiPath & arguments.objectName & ".cfc";

        if ( fileExists( filePath ) ) {
            throw( type="scaffoldPresideObject.restendpoint.exists", message="The REST endpoint for object '#arguments.objectName#' already exists ('#filePath#')" );
        }

        var swaggerAnnotations = "";

        if ( arguments.createSwaggerAnnotations ) {
            swaggerAnnotations =        "@swagger_tags #arguments.pluralObjectTitle#" & _nl()
                               & "     * @swagger_summary #arguments.singularObjectTitle#" & _nl()
                               & "     * @swagger_responses 200:single #lCase( arguments.singularObjectTitle )#;404:#lCase( arguments.singularObjectTitle )# not found";
        }

        var fileContent = FileRead( ExpandPath( "/app/extensions/preside-ext-rest-scaffold/services/devtools/scaffoldingResources/restEndpoint.cfc.txt" ) );

        fileContent = Replace( fileContent, "${uri}", arguments.uri );
        fileContent = Replace( fileContent, "${objectName}", arguments.objectName );
        fileContent = Replace( fileContent, "${singularObjectTitle}", lCase( arguments.singularObjectTitle ), "all" );
        fileContent = Replace( fileContent, "${swaggerAnnotations}", swaggerAnnotations );

        _ensureDirectoryExists( GetDirectoryFromPath( filePath ) );
        FileWrite( filePath, fileContent );

        return filePath;
    }

// PRIVATE HELPERS
    private string function _ensureLeadingSlash( required string path ) {

        if ( isEmpty( arguments.path ) ) {
            return "/";
        }

        if ( left( arguments.path, 1 ) == "/" ) {
            return arguments.path;
        }

        return "/" & arguments.path;            
    }

    private string function _ensureTrailingSlash( required string path ) {

        if ( isEmpty( arguments.path ) ) {
            return "/";
        }

        if ( right( arguments.path, 1 ) == "/" ) {
            return arguments.path;
        }

        return arguments.path &= "/";
    }

// GETTERS AND SETTERS
    private any function _getResourceBundleService() {
        return _resourceBundleService;
    }
    private void function _setResourceBundleService( required any resourceBundleService ) {
        _resourceBundleService = arguments.resourceBundleService;
    }
}