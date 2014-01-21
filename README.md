# Flat UI for Sass

`flat-ui-sass` is a SASS port of Designmodo's [Flat-UI Free](). `flat-ui-sass`
also provides rake tasks to convert and vendor [Flat-UI Pro]() for use with
Rails, Compass, and vanilla SASS.

## Dependencies

`flat-ui-sass` requires [`bootstrap-sass`](https://github.com/twbs/bootstrap-sass) as well as `sass` >= 3.3.0.rc.2 There are a few things that need
the features in the 3.3.x version of `sass`.

`flat-ui-sass` also depends on `term-ansicolor` right now for the logging
functionality of the converter. This is on the TODO list for removal.

Flat-UI itself depends on jQuery, jQuery UI, and various javascript
dependencies. This gem does not depend on any of these directly. A rake task
is on the TODO list for either generating bower entries or vendoring the the
files directly.

Finally, Flat-UI uses the [Lato](https://www.google.com/fonts/specimen/Lato)
font as its base font. This gem does not vendor Lato as there are better ways
of getting that font on the page

## Installation

### Rails

Add the following to your Gemfile:

    gem 'flat-ui-sass', github: 'wingrunr21/flat-ui-sass'

### Compass (no Rails)

### vanilla SASS (no Compass or Rails)

## Usage

### Rails

Import bootstrap and then Flat-UI in `application.css.scss`:

    @import 'boostrap';
    @import 'flat-ui';

For Flat-UI Pro, simply import `flat-ui-pro` instead:

    @import 'boostrap';
    @import 'flat-ui-pro';

Require jQuery, jQuery UI, javascript deps, and Flat-UI in
`application.js.coffee`:

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

Flat-UI and Flat-UI Pro both have the same javascript dependencies

## Roadmap

1. Add Flat-UI modules that are missing in Flat-UI Pro to the pro manifest
2. Add Rake task for downloading/vendoring various JS dependencies

## Development and Contributing

## Credits

The conversion scripts and general gem structure rely upon and are heavily
influenced by the work done on [bootstrap-sass](https://github.com/twbs/bootstrap-sass). This gem would not be possible without all of the hard work put into that project.

Thanks also go to [Designmodo](http://designmodo.com/) for creating and publishing Flat-UI.
