component {
    
    property name="rest_api_enabled"      type="boolean" dbtype="boolean"                                default="false";
    property name="rest_api_key"          type="string"  dbtype="varchar" maxlength="64" required="true" default="method:generateApiKey";
    property name="rest_api_last_access"  type="date"    dbtype="datetime";
    property name="rest_api_access_count" type="numeric" dbtype="int"                                    default="0";

    public string function generateApiKey() {
        return hash( createUUID() );
    }
}