# Homebrew ClickHouse Tap

This is an unofficial Homebrew repository for the Yandex's [ClickHouse](https://clickhouse.yandex/) DBMS.

It is relatively new and isn't tested well.  
Please consider appending the `--verbose` and `--debug` parameters to the `brew install` command to make it easier to debug the package installation.  
If you are having any problems with the precompiled binaries (bottles), append the `--build-from-source` parameter.

Issues and pull requests are always welcome!

## Usage

Add this repository:
```
brew tap samgaw/clickhouse
```

To install the latest `stable` release, run:
```
brew install clickhouse
```

Or, to install the `testing` release, run:

```
brew install clickhouse --devel
```

## Run the server

Make sure that you've increased the maxfiles parameter as described in [here](https://github.com/yandex/ClickHouse/blob/master/MacOS.md).  
Then, to run the server, run:
```
brew services start clickhouse
```
