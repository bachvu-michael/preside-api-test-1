<cfif isFeatureEnabled( "restSwagger" )>
	<cfsilent>
		<cfset specLink = event.buildLink( linkTo="swagger" ) />
		<cfset dashboardLink = event.buildLink( linkTo="swagger/ui" ) />	
	</cfsilent>
	<cfoutput>
		<h3>Swagger RESTful API Specification</h3>
		<h4>Specification</h4>
		<p>Find the generated Swagger 2.0 API Specification here:</p>
		<a href="#specLink#">#specLink#</a>
		<cfif prc.isSwaggerUiEnabled>
			<h4>Swagger UI</h4>
			<p>Use the following URL to get a dashboard including the API documentation and the possibility to try out endpoints.</p>
			<a href="#dashboardLink#">#dashboardLink#</a>
		</cfif>
		<h4>More info</h4>
		<a href="http://swagger.io">http://swagger.io</a><br>
		<a href="http://swagger.io/specification/">http://swagger.io/specification/</a><br>
		<a href="http://swagger.io/swagger-ui/">http://swagger.io/swagger-ui/</a>
	</cfoutput>
</cfif>