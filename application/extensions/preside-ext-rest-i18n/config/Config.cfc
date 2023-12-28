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

		interceptors.prepend(
			{ class="#appMappingPath#.extensions.preside-ext-rest-i18n.interceptors.RestMultilingualInterceptor", properties={} }
		);

		settings.features.restI18n = { enabled=true , siteTemplates=[ "*" ], widgets=[] };
	}
}