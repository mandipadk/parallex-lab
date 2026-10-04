# Parallex compatibility lab

Every night, on a clean Mac (a GitHub Actions macOS runner), the latest
released [Parallex](https://parallex.mandip.dev) is tried against the current
versions of popular apps. Each app is installed fresh with Homebrew, made into
an instance the way New Instance makes one by default (a copy with its own
Library, keychain, Guard and recorder, or for browsers a wrapper with a
profile folder of its own, and then a copy too), opened, and checked: does it
keep running, does it crash, and does it reach the original app's data?

The latest results are on
[parallex.mandip.dev/compatibility](https://parallex.mandip.dev/compatibility)
and on each app's page at [parallex.mandip.dev/apps](https://parallex.mandip.dev/apps).
The raw file is `compat-lab.json` on the
[`lab-results`](https://github.com/mandipadk/parallex-lab/tree/lab-results)
branch, replaced after every full run. Each run's summary and its
`compat-lab` artifact (with diagnostics for any instance that quit, crashed or
leaked) are under [Actions](https://github.com/mandipadk/parallex-lab/actions).

## What's here

- `fetch-parallex.sh` downloads the latest release from
  `parallex.mandip.dev/download/latest/Parallex.zip`, checks it against the
  checksum published with it, and unpacks `Parallex.app`.
- `compat-lab.sh` runs the lab with the `parallex` command inside that app
  (`Parallex.app/Contents/Resources/parallex`). Everything it makes goes in a
  folder and a Parallex library of its own, and is removed afterwards.
- `.github/workflows/compat-lab.yml` runs both every night and publishes the
  results.

## Running it yourself

On a Mac you don't mind opening apps on:

```sh
./fetch-parallex.sh
./compat-lab.sh --wait 30 --diagnose diagnostics "Visual Studio Code" Slack
```

Each app is looked up by its name in `/Applications`. With `--install`, an
`App=cask` argument installs the cask first, as CI does. Results go to
`compat-lab.json`, one line per app, and a table to the terminal.

From the Actions tab, **Run workflow** takes `only` (app names,
comma-separated) to try just some apps; those results are published only when
`publish` is ticked.

## Found a problem with an app?

Report it in
[parallex-community](https://github.com/mandipadk/parallex-community/issues/new?template=compatibility.yml).

## License

MIT
