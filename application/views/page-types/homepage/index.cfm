<cfoutput>
    <h1>Welcome to your Preside based REST API</h1>

    <p>This is the default landing page for a REST API application. It should not be used in production as is. Feel free to customize or remove it completely.</p>

    <h2>Preside Admin</h2>

    <p>Access the Preside admin <a href="#event.getAdminPath()#">here</a></p>

    <h2>App reload </h2>
    <p>Reload the whole application <a href="/?fwreinit=true">here</a></p>

    <cfif isFeatureEnabled( "restSwagger" )>
        <h2>Swagger</h2>

        <p>Get the generated Swagger Specification for the REST APIs <a href="/swagger">here</a></p>

        <cfset isSwaggerUiEnabled = getSystemSetting( category="rest-swagger", setting="enableSwaggerUi", default=true ) />

        <cfif isBoolean( isSwaggerUiEnabled ) && isSwaggerUiEnabled>
            <p>Access the Swagger UI <a href="/swagger/ui">here</a></p>
        </cfif>
    </cfif>
</cfoutput>