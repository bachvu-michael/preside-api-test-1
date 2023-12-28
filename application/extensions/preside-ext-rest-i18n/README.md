# Preside Extension: Multilingual REST request handling

This is an extension for [Preside](https://www.presidecms.com) that provides the ability to perform multilingual REST requests.

## Usage

The extension provides a system configuration screen that allows you to configure:

* *Support default HTTP header:* accept i18n requests that use 'Accept-language'
* *Custom HTTP Header:* optionally a custom HTTP request header to check for a valid language code (defaults to X-LANGUAGE)

*Accept-language* is a standard HTTP header field, see [Wikipedia](https://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Accept-Language) for details.

*If for any reason both headers are supplied, then Accept-language takes precedence.*

The following language formats can be used:

* en, fr, de, etc. (ISO 639-1 code)
* en-US, de-DE, etc. (in this case only the first part is evaluated as Preside currently only supports two-letter ISO 639-1 codes)

In case of an invalid language code, the system falls back to the default language.
The concept only works if your application deals with multilingual Preside objects.
Documentation: [Preside - Multilingual content](https://docs.presidecms.com/devguides/multilingualcontent.html)

### cURL example

See following example requests

    curl -X GET --header 'Accept-language: de-DE' 'http://servername:serverport/api/myrestapiendpoint/'
    curl -X GET --header 'Accept-language: en' 'http://servername:serverport/api/myrestapiendpoint/'
    curl -X GET --header 'X-LANGUAGE: fr-FR' 'http://servername:serverport/api/myrestapiendpoint/'

## Installation

Install the extension to your application via either of the methods detailed below (Git submodule / CommandBox) and then enable the extension by opening up the Preside developer console and entering:

    extension enable preside-ext-rest-i18n
    reload all

### Git Submodule method

From the root of your application, type the following command:

    git submodule add https://bitbucket.org/hwsdev/preside-ext-rest-i18n.git application/extensions/preside-ext-rest-i18n

### CommandBox (box.json) method

From the root of your application, type the following command:

    box install preside-ext-rest-i18n