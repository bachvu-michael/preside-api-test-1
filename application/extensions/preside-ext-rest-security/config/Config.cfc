component {

    public void function configure( required struct config ) {

        // core settings that will effect Preside
        var settings            = arguments.config.settings             ?: {};

        // other ColdBox settings
        var coldbox             = arguments.config.coldbox              ?: {};
        var i18n                = arguments.config.i18n                 ?: {};
        var interceptors        = arguments.config.interceptors         ?: [];
        var interceptorSettings = arguments.config.interceptorSettings  ?: {};
        var cacheBox            = arguments.config.cacheBox             ?: {};
        var wirebox             = arguments.config.wirebox              ?: {};
        var logbox              = arguments.config.logbox               ?: {};
        var environments        = arguments.config.environments         ?: {};

        var appMappingPath      = settings.appMappingPath               ?: "app";

        var coldboxMajorVersion = Val( ListFirst( settings.coldboxVersion ?: "", "." ) );

        settings.features.restSecurity = { enabled=true , siteTemplates=[ "*" ], widgets=[] };

        interceptors.prepend(
            { class="#appMappingPath#.extensions.preside-ext-rest-security.interceptors.RestSecurityInterceptor", properties={} }
        );

        if ( coldboxMajorVersion < 4 ) {
            logbox.appenders.restsecurityLogAppender = {
                  class      = 'coldbox.system.logging.appenders.AsyncRollingFileAppender'
                , properties = { filePath=settings.logsMapping, filename="restsecurity" }
            }
        }
        else {
            logbox.appenders.restsecurityLogAppender = {
                  class      = 'coldbox.system.logging.appenders.RollingFileAppender'
                , properties = { filePath=settings.logsMapping, filename="restsecurity", async=true }
            }
        }

        logbox.categories.restsecurity = {
              appenders = 'restsecurityLogAppender'
            , levelMin  = 'FATAL'
            , levelMax  = 'INFO'
        };
    }
}