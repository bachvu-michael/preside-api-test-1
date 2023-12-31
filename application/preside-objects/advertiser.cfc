/*
 * This preside object has been scaffolded by the Preside dev tools scaffolder
 *
 * For speed of scaffolding, we have just created all your properties with the default
 * settings. You will almost certainly want to define your properties in more detail
 * here. Some examples:
 *
 * property name="myTextField" type="string" dbtype="varchar" maxLength=200 required=true uniqueindexes="myUX|2";
 * property name="myFlag" type="boolean" dbtype="boolean" required=false default=false;
 * property name="somecategory" relationship="many-to-one" relatedto="some_category_object" required=true uniqueindexes="myUX|1;
 *
 * You should remove this comment once you are done with it.
 */

 
/**
 * @labelField first_name
 * @dataManagerGroup API
 */

component {
	property name="first_name" type="string" dbtype="varchar" maxLength=50;
	property name="last_name" type="string" dbtype="varchar" maxLength=50;
	property name="url" type="string" dbtype="varchar" maxLength=200;
	property name="category";
}