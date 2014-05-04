# DB5 Live

A version of DB5 that supports live updating of values from the plist while running the app on the simulator. Now you can make dozens of tweaks to your app in a matter of minutes!

See the demo app for an example:

1. Run the demo app
2. Change a value in the plist, and save it
3. Watch the app change before your eyes!

Note that this will not work on device.

To add it to your app:

1. Restructure your app delegate (or wherever you load VSThemes in your app) so that you can "refresh" your UI.
2. From this method, call `[themeLoader loadThemes];`
3. Register for file changes by setting the themeReloadedCallback block on themeLoader and have it refresh your UI.
4. Add a `Run Script` build step to your target:
    . $SRCROOT/../Source/VSSymlinkThemesScript.sh
See the demo app for an example, just look at the App Delegate

How it works:
After your app builds, the build script deletes your DB5.plist, and replaces it with a symlink to the source copy. On the simulator, this allows the app to load the updated file without rebuilding.

The code adds the additional magic of watching the file for changes. If the file changes, the callback gets called, which typically will cause your app to refresh. 

For more advanced usage, you could have this callback fire an NSNotification, so that individual View Controllers could reload themselves, rather than reloading the root view controller. This helps when working on a more complex app, as the feedback loop between change and result will be reduced to nearly zero.

## Other Neat Things

* A `CGRect`, `CGSize`, or a `CGPoint` can be defined using a string with comma syntax (ex. `0,0,30,20`)
* `UIColor` can be written in RGB and RGBA using commas, in 255 format (ex. `255,0,0`)
* `UIColor` has an optional alpha component when written in hex

# Original README
# DB5

by [Q Branch](http://qbranch.co/)

## App Configuration via Plist

By storing colors, fonts, numbers, booleans, and so on in a plist, we were able to iterate quickly on our app [Vesper](http://vesperapp.co/).

Our designers could easily make changes without having to dive into the code or ask engineering to spend time nudging pixels and changing values.

There is nothing magical about the code or the system: it’s some simple code plus a few conventions.

### How it works

See the demo app. You include two classes — `VSThemeLoader` and `VSTheme` — and DB5.plist. The plist is where you set values.

At startup you load the file via `VSThemeLoader`, then access values via methods in `VSTheme`.

#### VSTheme methods

Most of the methods are straightforward. `-[VSTheme boolForKey:]` returns a BOOL, and so on.

Some of the methods require multiple values in the plist file. For instance, `-[VSTheme fontForKey:]` expects the font name as `keyName` and the size as `keyNameSize`. See VSTheme.h for more information about these multiple-key values.

#### Inheritance

Though we haven’t used this capability in Vesper, we made it so that you can have multiple themes. Every theme inherits from the Default theme.

If you ask for a value from a theme other than Default, and that value is not specified in that theme, it falls back to Default to get that value.

### Demo app

The demo app is straightforward and small. `DB5AppDelegate` loads the themes. `DB5ViewController` shows some example use.

Also, see the Examples folder for the DB5.plist from Vesper.

### Contact

[Brent Simmons](https://github.com/brentsimmons)<br />
[@brentsimmons](https://twitter.com/brentsimmons)

### License

DB5 is available under the MIT license. See the LICENSE file for details.
