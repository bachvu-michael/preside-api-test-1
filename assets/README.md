Static assets for your web application
======================================

We've included a basic shell to help build the css / js for your application here with a Grunt task + sticker bundle file that should be enough for most use cases.

To add specific css or js for a particular admin action or handler, create a subfolder with all the `.less` or `.js` files with the following patterns:

```
/assets/js/admin/specific/myhandler/some.js
/assets/js/admin/specific/myhandler/myaction/some.js
/assets/css/admin/specific/myhandler/some.js
/assets/css/admin/specific/myhandler/myaction/some.js
```

Running `grunt` (and optionally `grunt watch` to auto rebuild on change) from this directory should then build the minified files ready for include in your Preside admin interface.