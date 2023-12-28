component {
	
	public void function configure( required struct config ) {

		// core settings that will effect Preside
		var settings       		= arguments.config.settings 			?: {};

		// other ColdBox settings
		var coldbox             = arguments.config.coldbox             	?: {};
		var i18n                = arguments.config.i18n                	?: {};
		var interceptors        = arguments.config.interceptors        	?: [];
		var interceptorSettings = arguments.config.interceptorSettings 	?: {};
		var cacheBox            = arguments.config.cacheBox            	?: {};
		var wirebox             = arguments.config.wirebox             	?: {};
		var logbox              = arguments.config.logbox              	?: {};
		var environments        = arguments.config.environments     	?: {};

		var appMappingPath 		= settings.appMappingPath				?: "app";

		var coldboxMajorVersion = Val( ListFirst( settings.coldboxVersion ?: "", "." ) );

		settings.features.restSwagger = { enabled=true , siteTemplates=[ "*" ], widgets=[] };

		interceptors.prepend(
			{ class="#appMappingPath#.extensions.preside-ext-rest-swagger.interceptors.RestSwaggerSettingsInterceptor", properties={} }
		);

    	settings.adminPermissions.swaggeradmin = [ "access" ];
    	
		settings.adminSideBarItems.append( "swaggeradmin" );

		if ( coldboxMajorVersion < 4 ) {
			logbox.appenders.restswaggerLogAppender = {
				  class      = 'coldbox.system.logging.appenders.AsyncRollingFileAppender'
				, properties = { filePath=settings.logsMapping, filename="restswagger" }
			}
		}
		else {
			logbox.appenders.restswaggerLogAppender = {
				  class      = 'coldbox.system.logging.appenders.RollingFileAppender'
				, properties = { filePath=settings.logsMapping, filename="restswagger", async=true }
			}
		}

		logbox.categories.restswagger = {
			  appenders = 'restswaggerLogAppender'
			, levelMin  = 'FATAL'
			, levelMax  = 'INFO'
		};
	}
}