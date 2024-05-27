A simple script to generate a dash docset from the [Haiku API Documentation](https://www.haiku-os.org/docs/api/)

You must have `git`, `doxygen`, `doxygen2docset`, and `sqlite3` installed.

Usage:
```
cd haikubook2docset
./build.sh
```

By default the output will by put into the `generated` directory.  This can be overridden by passing a path to the `build.sh` script, like `build.sh /path/to/build/directory`.
