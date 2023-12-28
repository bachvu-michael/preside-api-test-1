component extends="preside.system.Bootstrap" {
	super.setupApplication( id = "mickAPI" );
	this.serialization.preserveCaseForStructKey=true;
	function onError() { dump( arguments ); abort; } 
}