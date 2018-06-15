# EnTT homebrew formula

This is the [homebrew](https://brew.sh/) formula for [EnTT](https://github.com/skypjack/entt#introduction).

Install with this command:

    brew install skypjack/entt/entt

Alternatively:

    brew tap skypjack/entt
    brew install entt

Pass the `--with-docs` option to build and install the documentation

    brew install skypjack/entt/entt --with-docs

The documentation is built with `cmake` and `doxygen --with-graphviz` and can be found in the 
keg or `/usr/local/share/entt-{version}/html`.

Pass the `--HEAD` option to download the very latest commit from the master branch

    brew install skypjack/entt/entt --HEAD
