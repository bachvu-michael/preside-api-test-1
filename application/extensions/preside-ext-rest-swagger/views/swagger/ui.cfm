<cfsilent>
    <cfparam name="prc.apitoken"              default="" />
    <cfparam name="prc.swaggerSpecURL"        default="" />
    <cfparam name="prc.isRestSecurityEnabled" default="" />
</cfsilent>
<cfoutput>
    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="UTF-8">
            <title>Swagger UI</title>

            <link rel="icon" type="image/png" href="#event.buildLink( systemStaticAsset='/extension/preside-ext-rest-swagger/assets/images/favicon-32x32.png' )#" sizes="32x32" />
            <link rel="icon" type="image/png" href="#event.buildLink( systemStaticAsset='/extension/preside-ext-rest-swagger/assets/images/favicon-16x16.png' )#" sizes="16x16" />

            <link href='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/css/typography.css" )#' media='screen' rel='stylesheet' type='text/css'/>
            <link href='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/css/reset.css" )#' media='screen' rel='stylesheet' type='text/css'/>
            <link href='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/css/screen.css" )#' media='screen' rel='stylesheet' type='text/css'/>
            <link href='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/css/reset.css" )#' media='print' rel='stylesheet' type='text/css'/>
            <link href='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/css/print.css" )#' media='print' rel='stylesheet' type='text/css'/>

            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/jquery-1.8.0.min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/jquery.slideto.min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/jquery.wiggle.min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/jquery.ba-bbq.min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/handlebars-2.0.0.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/underscore-min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/backbone-min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/swagger-ui.min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/highlight.7.3.pack.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/jsoneditor.min.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/marked.js" )#' type='text/javascript'></script>
            <script src='#event.buildLink( systemStaticAsset="/extension/preside-ext-rest-swagger/assets/js/lib/swagger-oauth.js" )#' type='text/javascript'></script>

            <!-- Some basic translations -->
            <!-- <script src='/api/swagger-ui/lang/translator.js' type='text/javascript'></script> -->
            <!-- <script src='/api/swagger-ui/lang/en.js' type='text/javascript'></script> -->

            <script type="text/javascript">
                $( function() {
                    var url = '#prc.swaggerSpecURL#';

                    // Pre load translate...
                    if ( window.SwaggerTranslator ) {
                        window.SwaggerTranslator.translate();
                    }
                    window.swaggerUi = new SwaggerUi( {
                        url: url,
                        validatorUrl: undefined,
                        dom_id: "swagger-ui-container",
                        supportedSubmitMethods: [ 'get', 'post', 'put', 'delete', 'patch' ],
                        onComplete: function( swaggerApi, swaggerUi ) {
                            if ( typeof initOAuth == "function" ) {
                                initOAuth( {
                                    clientId: "your-client-id",
                                    clientSecret: "your-client-secret-if-required",
                                    realm: "your-realms",
                                    appName: "your-app-name", 
                                    scopeSeparator: ",",
                                    additionalQueryStringParams: {}
                                } );
                            }

                            if ( window.SwaggerTranslator ) {
                                window.SwaggerTranslator.translate();
                            }

                            $( 'pre code' ).each( function( i, e ) {
                                hljs.highlightBlock( e );
                            } );

                            <cfif prc.isRestSecurityEnabled>
                                addApiKeyAuthorization();
                            </cfif>
                        },
                        onFailure: function( data ) {
                            log( "Unable to Load SwaggerUI" );
                        },
                        docExpansion: "none",
                        jsonEditor: false,
                        apisSorter: "alpha",
                        defaultModelRendering: 'schema',
                        showRequestHeaders: true
                    } );

                    <cfif prc.isRestSecurityEnabled>
                        function addApiKeyAuthorization() {
                            var key = encodeURIComponent( $( '##input_apiKey' )[ 0 ].value );
                            if ( key && key.trim() != "" ) {
                                var apiKeyAuth = new SwaggerClient.ApiKeyAuthorization( "X-API-KEY", key, "header" );
                                window.swaggerUi.api.clientAuthorizations.add( "api_key", apiKeyAuth );
                                log( "added key " + key );
                            }
                        }

                        $( '##input_apiKey' ).change( addApiKeyAuthorization );

                        <cfif len( prc.apitoken ) gt 0>
                            var apiKey = "#prc.apitoken#";
                            $( '##input_apiKey' ).val( apiKey );
                        </cfif>
                    </cfif>

                    window.swaggerUi.load();

                    function log() {
                        if ( 'console' in window ) {
                            console.log.apply( console, arguments );
                        }
                    }
                });
            </script>
        </head>
        <body class="swagger-section">
            <div id='header'>
                <div class="swagger-ui-wrap">
                    <a id="logo" href="http://swagger.io">swagger</a>
                    <form id='api_selector'>
                        <div class='input'>
                            <input placeholder="http://example.com/api" id="input_baseUrl" name="baseUrl" type="text" disabled />
                        </div>
                        <cfif prc.isRestSecurityEnabled>
                            <div class='input'>
                                <input placeholder="api_key" id="input_apiKey" name="apiKey" type="text" />
                            </div>
                        </cfif>
                        <div class='input'>
                            <a id="explore" href="##" data-sw-translate>Explore</a>
                        </div>
                    </form>
                </div>
            </div>

            <div id="message-bar" class="swagger-ui-wrap" data-sw-translate>&nbsp;</div>
            <div id="swagger-ui-container" class="swagger-ui-wrap"></div>
        </body>
    </html>
</cfoutput>