component extends="preside.system.config.Config" {

	public void function configure() {
		super.configure();

		settings.preside_admin_path  = "admin";
		settings.system_users        = "sysadmin";
		settings.default_locale      = "en";

		settings.default_log_name    = "mickAPI";
		settings.default_log_level   = "information";
		settings.sql_log_name        = "mickAPI";
		settings.sql_log_level       = "information";

		settings.features.restSwagger.enabled   = true;
		settings.features.restSecurity.enabled  = false;
		settings.features.restI18n.enabled      = false;

		settings.features.websiteUsers.enabled  = false;
		settings.features.multilingual.enabled  = false;

		settings.features.datamanager.enabled   = true;
		settings.features.assetManager.enabled  = true;
		settings.features.cms.enabled           = true;
		settings.features.sites.enabled         = false;
		settings.features.sitetree.enabled      = false;

		StructDelete( settings.adminPermissions, "sites"    );
		StructDelete( settings.adminPermissions, "sitetree" );

		settings.adminApplications = [{
			  id                 = "cms"
			, feature            = "cms"
			, defaultEvent       = "admin.datamanager"
			, accessPermission   = "cms.access"
			, activeEventPattern = "admin\..*"
			, layout             = "admin"
		}];
	}
}