/**
 * @dataManagerGroup rest
 * @feature restSecurity
 * @dataManagerGridFields label,key,active,last_access,access_count,datecreated,datemodified
 */
component {
    
	property name="key"          type="string"  dbtype="varchar" maxlength="64" required="true" default="method:generateApiKey" uniqueIndexes="key";
	property name="active"       type="boolean" dbtype="boolean" default="true";
	property name="last_access"  type="date"    dbtype="datetime";
	property name="access_count" type="numeric" dbtype="int"     default="0";

    public string function generateApiKey() {
        return hash( createUUID() );
    }
}