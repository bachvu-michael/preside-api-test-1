# Preside Extension: Basic REST Security

This is an extension for [Preside](https://www.presidecms.com) that provides a simple authentication mechanism for the in-built REST API architecture.

## Configuration

The extension provides a system configuration screen that allows you to configure:

* *Enabled:* You can globally enable/disable security. Warning: if disabled, your API can be accessed without a key
* *Master API Key:* an API key that is required for each request to the Preside REST API
* *HTTP Header name:* the HTTP request header that is checked for the provided API Key (defaults to X-API-KEY)
* *Enable API Key management:* Whether multiple API keys are supported - see below
* *Enable website user Basic Auth:* Whether HTTP Basic Authentication is enabled or not (option only available if websiteusers feature is enabled)
* *Track API key usage:* If multiple API key management is enabled, use this option to track access

## Usage

Use one of the configured API keys in all REST request in the defined custom HTTP header.

If multiple API key management is enabled the keys defined in the data manager are evaluated as well. They can be labelled and therefore different remote applications can be easily identified.
In addition it is possible to enable usage tracking. If enabled, each key's usage will be monitored, counting the number of requests as well as storing the last access timestamp.

If website users are enabled then it is possible to have one key per user. Individual access can be enabled per user as well.
It's up to you how a user can get the key. Out-of-the-box it is only available within the website user management in the Preside Admin.

If featue websiteusers is enabled you can use HTTP basic auth on each REST request to authenticate the request. Enable the support for Basic Auth in the system settings.

### cURL example

In the following example the header *X-API-KEY* is used and the configured valid API key is *3635F2A8CB840264EA3BC0FF179E25B8*

    curl -X GET --header 'Accept: application/json' --header 'X-API-KEY: 3635F2A8CB840264EA3BC0FF179E25B8' 'http://servername:serverport/api/myrestapiendpoint/'

### Results

The following responses are returned in case of errors. In these cases the response content is always empty and the detail error message is returned in the custom HTTP response header *X-ERROR-MESSAGE*.

    HTTP/1.1 401 Not Authenticated
    Connection: close
    X-ERROR-MESSAGE: Missing HTTP header 'X-API-KEY'
    Content-Type: application/json;charset=utf-8
    Content-Length: 0
    Date: Mon, 22 Feb 2016 14:37:16 GMT

    HTTP/1.1 401 Not Authenticated
    Connection: close
    X-ERROR-MESSAGE: Empty HTTP header 'X-API-KEY'
    Content-Type: application/json;charset=utf-8
    Content-Length: 0
    Date: Mon, 22 Feb 2016 14:42:13 GMT

    HTTP/1.1 403 Not Authorized
    Connection: close
    X-ERROR-MESSAGE: Invalid API Key. Please use a valid API key in HTTP header 'X-API-KEY'
    Content-Type: application/json;charset=utf-8
    Content-Length: 0
    Date: Mon, 22 Feb 2016 14:49:34 GMT


*X-API-KEY within X-ERROR-MESSAGE will differ if you have configured a custom HTTP header name.*

## Logging

The extension defines a 'restsecurity' logbox logger that, by default, logs to `(yourapp)/logs/restsecurity.log`. Warnings, errors and info will be recorded here.

## Installation

Install the extension to your application via either of the methods detailed below (Git submodule / CommandBox) and then enable the extension by opening up the Preside developer console and entering:

    extension enable preside-ext-rest-security
    reload all

### Git Submodule method

From the root of your application, type the following command:

    git submodule add https://bitbucket.org/hwsdev/preside-ext-rest-security.git application/extensions/preside-ext-rest-security

### CommandBox (box.json) method

From the root of your application, type the following command:

    box install preside-ext-rest-security

## Ideas for the future
* possibility to bypass authentication for local development environment
* additional authentication methods
* maybe rate-limiting / throttling (general and apikey-specific)