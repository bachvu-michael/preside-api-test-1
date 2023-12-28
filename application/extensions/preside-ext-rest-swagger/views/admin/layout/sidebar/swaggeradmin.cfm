<cfif isFeatureEnabled( "restSwagger" ) && hasCmsPermission( "swaggeradmin.access" )>
    <cfoutput>
        #renderView( view="/admin/layout/sidebar/_menuItem", args={
              active = reFindNoCase( "swaggeradmin$", event.getCurrentHandler() )
            , title  = translateResource( uri="swaggeradmin:menu.title" )
            , link   = event.buildAdminLink( linkTo="swaggeradmin" )
            , icon   = "fa-tachometer"
        } )#
    </cfoutput>
</cfif>