component extends="preside.system.base.AdminHandler" {

    property name="systemConfigurationService" inject="delayedInjector:systemConfigurationService";

	function index( event, rc, prc ) {
        if ( !isFeatureEnabled( "restSwagger" ) ) {
            event.notFound();
        }

        var isSwaggerUiEnabled = systemConfigurationService.getSetting(
              category = "rest-swagger"
            , setting  = "enableSwaggerUi"
            , default  = true
        );
        
        prc.isSwaggerUiEnabled = isBoolean( isSwaggerUiEnabled ) && isSwaggerUiEnabled;
	}
}