# Flat UI for Sass

`flat-ui-sass` is a SASS port of Designmodo's [Flat-UI Free](http://designmodo.github.io/Flat-UI/). `flat-ui-sass`
also provides a rake task to convert and vendor [Flat-UI Pro](http://designmodo.com/flat/) for use with
Rails, Compass, and vanilla SASS.

#####This gem is currently under development! Things are broken and may not work correctly.

## Dependencies

`flat-ui-sass` requires [`bootstrap-sass`](https://github.com/twbs/bootstrap-sass) as well as `sass >= 3.3.0.rc.2`.

Right now you need to be running the master branch of `bootstrap-sass` for the
converter to run:

    gem 'bootstrap-sass', github:'twbs/bootstrap-sass'

`flat-ui-sass` also depends on `term-ansicolor` right now for the logging
functionality of the converter. This is on the TODO list for removal.

Flat-UI uses the [Lato](https://www.google.com/fonts/specimen/Lato)
font as its base font. This gem does not vendor Lato. It is up to you to make
sure Lato is available on your page.

## Installation

### Rails

Add the following to your Gemfile:

    gem 'flat-ui-sass', github: 'wingrunr21/flat-ui-sass'

### Compass (no Rails)

Not done yet

### vanilla SASS (no Compass or Rails)

Not done yet

## Usage

### Converting Flat-UI Pro

You can use the conversion script packaged along with `flat-ui-sass` to
automatically convert and vendor Flat-UI Pro to your local application:

1. Place the Flat-UI-Pro directory (e.g. the one with the less, js, font, image,
   etc files in it) in a directory at the root of your app titled `flat-ui-pro`
2. Run `bundle exec rake flat_ui_pro:convert`. You should see a lot of output
   regarding the conversion process. When it is finished, Flat-UI Pro should be
converted and available in the `vendor/assets/` directory.

### Rails

#### SCSS

Import bootstrap and then Flat-UI in `application.css.scss`:

    @import 'boostrap';
    @import 'flat-ui';

For Flat-UI Pro, simply import `flat-ui-pro` instead:

    @import 'boostrap';
    @import 'flat-ui-pro';

#### Javascript
Flat-UI has a lot of javascript dependencies. It is up to you to make sure the
appropriate javascript files are available in your appliction. The below are
example dependencies as used in the `index.html` demo page.

In `application.js`:

    //= require jquery
    //= require jquery.ui.core
    //= require jquery.ui.widget
    //= require jquery.ui.mouse
    //= require jquery.ui.position
    //= require jquery.ui.slider
    //= require jquery.ui.tooltip
    //= require jquery.ui.effect
    //= require jquery.ui.touch-punch.min
    //= require bootstrap
    //= require bootstrap-select
    //= require bootstrap-switch
    //= require flat-ui
    //= require jquery.tagsinput
    //= require jquery.placeholder
    //= require jquery.stacktable

For Flat-UI Pro:

    //= require jquery
    //= require jquery.ui.core
    //= require jquery.ui.widget
    //= require jquery.ui.mouse
    //= require jquery.ui.position
    //= require jquery.ui.button
    //= require jquery.ui.datepicker
    //= require jquery.ui.slider
    //= require jquery.ui.spinner
    //= require jquery.ui.tooltip
    //= require jquery.ui.effect
    //= require jquery.ui.touch-punch.min
    //= require bootstrap
    //= require bootstrap-select
    //= require bootstrap-switch
    //= require flat-ui-pro
    //= require jquery.tagsinput
    //= require jquery.placeholder
    //= require jquery.stacktable
    //= require bootstrap-typeahead

### Compass (no Rails)

Not done yet

### vanilla SASS (no Compass or Rails)

Not done yet

## Roadmap

1. Add Flat-UI modules that are missing in Flat-UI Pro to the Pro manifest
2. Add Rake task for downloading/vendoring various JS dependencies
3. Remove `term-ansicolor` dependency in converter
4. More user-friendly logging

## Development and Contributing

This gem uses a modified version of the converter utilized in [bootstrap-sass](https://github.com/twbs/bootstrap-sass). The converter runs over the checked-out Flat-UI git submodule and vendors the resulting files in `vendor/assets`. The converter does the following:

* Converts the LESS to SASS, fixing `@import` orders to load correct under SASS.
* Generates a `flat-ui.scss` or `flat-ui-pro.scss` manifest
* Copies Flat-UI javascript files and generates a `flat-ui.js` or
  `flat-ui-pro.js` manifest
* Copies the Flat-UI Icons font
* Copies supporting Flat-UI images

The converter is located in `lib/tasks/`

Version numbers for the current versions of Flat-UI and Flat-UI Pro that the
converter works against are in `version.rb`

### Developing

1. Clone this repository to a working directory
2. Initialize the Flat-UI submodule (`git submodule update --init`)
3. Create a new topic branch for your changes (`git checkout -b my_new_feature`)
4. Make some changes
5. Run `rake flat_ui:convert` to convert Flat-UI and vendor it

## Credits

The conversion scripts and general gem structure rely upon and are heavily
influenced by the work done on [bootstrap-sass](https://github.com/twbs/bootstrap-sass). This gem would not be possible without all of the hard work put into that project.

Thanks also go to [Designmodo](http://designmodo.com/) for creating and publishing Flat-UI.
