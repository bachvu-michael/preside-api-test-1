# Preside Extension: REST API Endpoint Scaffolding

This is an extension for [Preside](https://www.preside.org) that adds scaffolding capabilities.
For details on the REST framework implementation see here: [Preside REST Framework Documentation](https://docs.presidecms.com/devguides/restframework.html)

## Usage

Access the developer terminal in the Preside admin.
Then use the command 

    new restendpoint

and follow the wizard.

This should by default only work on a local machine.

## Installation

Install the extension to your application via either of the methods detailed below (Git submodule / CommandBox) and then enable the extension by opening up the Preside developer console and entering:

    extension enable preside-ext-rest-scaffold
    reload all

### Git Submodule method

From the root of your application, type the following command:

    git submodule add https://bitbucket.org/hwsdev/preside-ext-rest-scaffold.git application/extensions/preside-ext-rest-scaffold

### CommandBox (box.json) method

From the root of your application, type the following command:

    box install preside-ext-rest-scaffold

## Open tasks and ideas for the future

* support to generate endpoint verbs for write actions (PATCH/PUT, POST, DELETE)
* support for detailed response models (swagger annotations)
* scaffolding of page types