### Nugget

Nugget is a service for performing http and tcp integration tests. It uses [turd](https://github.com/joewilliams/turd/) under the covers to verify urls are responding properly.

#### Usage

The examples directory includes an example config file. The config file is a json description of tests you want to run.

The following starts nugget up in daemon mode. In this mode nugget just loops performing tests and writing the results in json to `/tmp/nugget_results.json`.

        $ nugget -c examples/config.json -d

Running nugget once is also possible.

        $ nugget -c examples/config.json

Nugget also includes a very basic web service daemon that simply reads the current results file.

        $ nugget -w

Additionally, nugget includes support for sending results of the tests to [backstop](https://github.com/obfuscurity/backstop).

#### License

nugget is open source software available under the MIT License