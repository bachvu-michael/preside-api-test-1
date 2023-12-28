A skeleton Preside application to be used as a starting point for a REST API application.

### Important

This package should be installed using the `preside new site` command from CommandBox rather than directly. See [Preside Commands](https://www.forgebox.io/view/preside-commands).

### Dependencies

There are 4 dependencies in form of Preside extensions that are automatically setup for you via CommandBox box.json

* [preside-ext-rest-i18n](https://www.forgebox.io/view/preside-ext-rest-i18n)
* [preside-ext-rest-security](https://www.forgebox.io/view/preside-ext-rest-security)
* [preside-ext-rest-scaffold](https://www.forgebox.io/view/preside-ext-rest-scaffold)
* [preside-ext-rest-swagger](https://www.forgebox.io/view/preside-ext-rest-swagger)

### Usage

To get you up and running quickly here is a sample scenario of what you would do to start using the REST skeleton:

#### CommandBox Package Management

Use CommandBox to setup your site

    mkdir myApiProject --cd
    preside new site

Follow the wizard, use for example:

* skeleton: myApiProject
* site-id: myApiProject
* admin path: admin (remember this one to be able to access the admin later)
* site name: My Awesome REST API Project
* site author: Me

#### Database

Create an empty database schema in mysql or mariadb that can be used by Preside.

#### CommandBox Lucee Server

Use CommandBox to start the server (make sure that you are in your apps root dir)

    preside start

Setup MySQL datasource now [Y/n]? y
enter DB info (name, user, server, etc.)

You should now see a blank homepage.

#### Configuration / Initial setup

Access the Preside Admin by appending /admin to the URL, e.g. http://127.0.0.1:12345/admin
If you chose a different admin path in the wizard, append that accordingly.
If you forgot what admin path you took or want to change it now, you can do that in the Config.cfc of your project.

Setup the sysadmin (super user that can do everything in the admin) by entering an email address and password.
Login using username _sysadmin_ and the password you just entered

#### System configuration

Have a look in the Config.cfc and enable features as required.

#### System settings

Check out the system settings in the Preside Admin (Rest Security, Rest i18n, Rest Swagger)

#### Swagger

Have a look at the generated Swagger spec and the Swagger UI - both have quick links from the Admin.

#### Scaffold REST endpoints

If you have defined some Preside objects you can quickly scaffold basic REST endpoints for those. Use the Preside developer terminal for that.

#### Play with the code and customize the application

Have fun trying out Preside goodness, explore the existing code and customize to your desire.

Feel free to fork and contribute. Feedback is welcome - probably best on the Preside Slack.