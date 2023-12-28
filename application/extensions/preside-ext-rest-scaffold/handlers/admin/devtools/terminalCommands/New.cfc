component hint="Create various preside system entities such as widgets and page types" {

    property name="jsonRpc2Plugin"     inject="coldbox:myPlugin:JsonRpc2";
    property name="restEndpointScaffoldingService" inject="restEndpointScaffoldingService";

    private function index( event, rc, prc ) {
        var params = jsonRpc2Plugin.getRequestParams();
        var validTargets = [ "widget", "terminalcommand", "pagetype", "object", "extension", "configform", "formcontrol", "emailtemplate", "ruleexpression", "restendpoint" ];

        params = IsArray( params.commandLineArgs ?: "" ) ? params.commandLineArgs : [];

        if ( !params.len() || !ArrayFindNoCase( validTargets, params[1] ) ) {
            return Chr(10) & "[[b;white;]Usage:] new target_type" & Chr(10) & Chr(10)
                           & "Valid target types:" & Chr(10) & Chr(10)
                           & "    [[b;white;]widget]          : Creates files for a new preside widget." & Chr(10)
                           & "    [[b;white;]pagetype]        : Creates files for a new page type." & Chr(10)
                           & "    [[b;white;]object]          : Creates a new preside object." & Chr(10)
                           & "    [[b;white;]extension]       : Creates a new preside extension." & Chr(10)
                           & "    [[b;white;]configform]      : Creates a new system config form." & Chr(10)
                           & "    [[b;white;]formcontrol]     : Creates a new form control." & Chr(10)
                           & "    [[b;white;]emailtemplate]   : Creates a new email template." & Chr(10)
                           & "    [[b;white;]ruleexpression]  : Creates a new rules engine expression" & Chr(10)
                           & "    [[b;white;]restendpoint]    : Creates a new REST endpoint." & Chr(10)
                           & "    [[b;white;]terminalcommand] : Creates a new terminal command!" & Chr(10);
        }

        return runEvent( event="admin.devtools.terminalCommands.new.#params[1]#", private=true, prePostExempt=true );
    }

    private function restendpoint( event, rc, prc ) {
        var params               = jsonRpc2Plugin.getRequestParams();
        var userInputPrompts     = [];

        if ( !StructKeyExists( params, "id" ) ) {
            ArrayAppend( userInputPrompts, { prompt="Object ID, e.g. myobject: ", required=true, paramName="id"} );
        }
        if ( !StructKeyExists( params, "apiPath" ) ) {
            ArrayAppend( userInputPrompts, { prompt="REST API root path, e.g. /myapi or /myapi/v1: ", required=true, paramName="apiPath"} );
        }
        if ( !StructKeyExists( params, "uri" ) ) {
            ArrayAppend( userInputPrompts, { prompt="REST URI, e.g. /myobjects/: ", required=false, paramName="uri"} );
        }
        if ( !StructKeyExists( params, "createSwaggerAnnotations" ) ) {
            ArrayAppend( userInputPrompts, { prompt="Create Swagger annotations?", required=true, default="Y", paramName="createSwaggerAnnotations", validityRegex="^[YyNn]$" } );
        }
        if ( !StructKeyExists( params, "extension" ) ) {
            ArrayAppend( userInputPrompts, { prompt="Extension name, leave blank for no extension: ", required=false, paramName="extension"} );
        }

        if ( ArrayLen( userInputPrompts ) ) {
            return {
                  echo        = Chr(10) & "[[b;white;]:: Welcome to the new REST endpoints wizard]" & Chr(10) & Chr(10)
                , inputPrompt = userInputPrompts
                , method      = "new"
                , params      = params
            };
        }

        var filesCreated = [];
        try {
            filesCreated = restEndpointScaffoldingService.scaffoldRestEndpoint(
                  objectName               = params.id
                , apiPath                  = params.apiPath
                , uri                      = params.uri
                , createSwaggerAnnotations = ( params.createSwaggerAnnotations == "y" ? true : false )
                , extension                = params.extension
            );
        } catch ( any e ) {
            return Chr(10) & "[[b;red;]Error creating REST endpoints for #params.id# object:] [[b;white;]#e.message#]" & Chr(10);
        }

        var msg = Chr(10) & "[[b;white;]The REST endpoints for object '#params.id#', has been scaffolded.] The following files were created:" & Chr(10) & Chr(10);
        for( var file in filesCreated ) {
            msg &= "    " & file & Chr(10);
        }

        return msg;
    }
}