# Flat UI for Sass

`flat-ui-sass` is a SASS port of Designmodo's [Flat-UI Free](http://designmodo.github.io/Flat-UI/). `flat-ui-sass`
also provides a rake task to convert and locally vendor [Flat-UI Pro](http://designmodo.com/flat/) for use with
Rails, Compass, and vanilla SASS.

##### This gem is currently under development! Things may be broken!

## Dependencies

`flat-ui-sass` requires [`bootstrap-sass`](https://github.com/twbs/bootstrap-sass)

`flat-ui-sass` depends on `term-ansicolor` right now for the logging
functionality of the converter. This is on the roadmap for removal.

Flat-UI uses the [Lato](https://www.google.com/fonts/specimen/Lato)
font as its base font. This gem does not vendor Lato. It is up to you to make
sure Lato is available on your page.

#### Notice:

The preferred version of sass is v3.3.0+. Unfortunately, this version is not
supported by sass-rails >= v4.0.2. If you run on sass v3.2.x, the only thing
that will not work properly is the color swatch module in Flat-UI Free. The only
other difference is in how the Flat-UI asset helper is discovered (see
`_variables.scss`).

## Installation

### Rails

Add the following to your Gemfile:

    gem 'flat-ui-sass', github: 'wingrunr21/flat-ui-sass'

### Compass (no Rails, Flat-UI free only right now)

Install the gem:

    gem install flat-ui-sass

or add it to your Gemfile:

    gem 'flat-ui-sass', github: 'wingrunr21/flat-ui-sass'

For existing projects:

    # config.rb:
    require 'flat-ui-sass'

    bundle exec compass install flat-ui

For new projects:

    bundle exec compass create new_project -r flat-ui-sass --using flat-ui

The resulting Compass project will have all Flat-UI JS/fonts/images as well as
the bootstrap JS/fonts.

The following SCSS files will also be created:

* [_variables.scss](/templates/project/_variables.scss.erb) - all of the Flat UI variables (override them here).
* [styles.scss](/templates/project/styles.scss) - primary SCSS file, import `variables`, `flat-ui/variables`, `bootstrap`, and `flat-ui`.

### vanilla SASS (no Compass or Rails)

Install the gem:

    gem install flat-ui-sass

or add it to your Gemfile:

    gem 'flat-ui-sass', github: 'wingrunr21/flat-ui-sass'

Follow the JS and Fonts setup instructions for [bootstrap-sass](https://github.com/twbs/bootstrap-sass#js-and-fonts)

In addition, you will need to copy font, image, and javascript assets out of
flat-ui-sass if you are using Flat-UI Free:

    mkdir public/images
    cp -r $(bundle show flat-ui-sass)/vendor/assets/images/ public/images
    cp -r $(bundle show flat-ui-sass)/vendor/assets/fonts/ public/fonts/
    cp -r $(bundle show flat-ui-sass)/vendor/assets/javascripts/ public/javascripts/

If you are using Flat-UI Pro, you can copy or symlink the various assets out of
the local vendor/assets directory in the root of your project.

Similar to bootstrap-sass, we provide Ruby methods to report the appropriate
paths:

    FlatUI.stylesheets_path
    FlatUI.fonts_path
    FlatUI.javascripts_path
    FlatUI.images_path

## Usage

### Converting Flat-UI Pro

You can use the `fui_convert` command packaged along with `flat-ui-sass` to
automatically convert and vendor Flat-UI Pro to your local application:

1. Place the Flat-UI Pro directory (e.g. the one with the less, js, font, image,
   etc files in it) in a directory at the root of your app titled `flat-ui-pro`
2. Run `bundle exec fui_convert`. You should see a lot of output
   regarding the conversion process. When it is finished, Flat-UI Pro should be
   converted and available in the `vendor/assets/` directory.

See `fui_convert --help` for more advanced usage

#### SCSS

Import the Flat-UI variables, bootstrap, and then Flat-UI:

    @import 'flat-ui/variables';
    @import 'bootstrap';
    @import 'flat-ui';

For Flat-UI Pro, simply import `flat-ui-pro` instead:

    @import 'flat-ui-pro/variables';
    @import 'bootstrap';
    @import 'flat-ui-pro';

You must import the Flat-UI variables before bootstrap, otherwise bootstrap's
variables will take priority!

##### Missing Modules

Flat-UI Pro does not include a few modules that exist in Flat-UI Free.
Designmodo has stated this is because [they are not yet mobile-ready](https://github.com/designmodo/Flat-UI-Pro-Support/issues/419#issuecomment-39879885). If you
still wish to use these modules, you can import them from this gem's version of
Flat-UI Free:

    @import 'flat-ui/modules/footer';
    @import 'flat-ui/modules/login';
    @import 'flat-ui/modules/palette';
    @import 'flat-ui/modules/share';
    @import 'flat-ui/modules/tile';
    @import 'flat-ui/modules/todo';

#### Javascript
Flat-UI has a lot of javascript dependencies. It is up to you to make sure the
appropriate javascript files are available in your application. For a reference,
check out the bottom of the `index.html` example page for your version of
Flat-UI or the list below.

If you are using Rails or Sprockets, you may require the manifest for all
javascript assets:

Free:

    //= require flat-ui

Pro:

    //= require flat-ui-pro

Alternatively, you may require individual modules as well

Free:

    //= require flat-ui/flatui-checkbox
    //= require flat-ui/flatui-radio

Pro:

    //= require flat-ui-pro/flatui-checkbox
    //= require flat-ui-pro/flatui-radio
    //= require flat-ui-pro/flatui-fileinput

Here's a list of javascript dependencies in Flat-UI Free:

* jquery
* jquery.ui.core
* jquery.ui.widget
* jquery.ui.mouse
* jquery.ui.position
* jquery.ui.slider
* jquery.ui.tooltip
* jquery.ui.effect
* jquery.ui.touch-punch.min
* bootstrap
* bootstrap-select
* bootstrap-switch
* jquery.tagsinput
* jquery.placeholder
* jquery.stacktable
* video.js

In addition, Flat-UI Pro also requires:

* jquery.ui.button
* jquery.ui.datepicker
* jquery.ui.spinner
* typeahead.js
* holder.js

#### Icon Helper
A Rails helper is also included to aid with using the Flat-UI glyph icons:

    fui_icon "heart"
    # => <i class="fui-heart"></i>

    fui_icon "heart", tag: :span
    # => <span class="fui-heart"></span>

    fui_icon "heart", text: "Flat-UI!"
    # => <i class="fui-heart"></i> Flat-UI!
    fui_icon "arrow-right", text: "Get started", right: true
    # => Get started <i class="fui-arrow-right"></i>

    fui_icon "photo", class: "pull-left"
    # => <i class="fui-photo pull-left"></i>

    fui_icon "user", data: { id: 123 }
    # => <i class="fui-user" data-id="123"></i>

    content_tag(:li, fui_icon("check", text: "Bulleted list item"))
    # => <li><i class="fui-check"></i> Bulleted list item</li>

## Roadmap

1. bower support
2. Tests

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
