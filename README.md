# Homebrew tap for Sarvkrit

[Sarvkrit](https://sarvkrit.com) is a macOS menu-bar utility that fixes the things macOS
does differently than you'd expect. Sixteen features, each an independent toggle, all
shipped switched off.

```sh
brew install --cask sadana-psylief/tap/sarvkrit
```

Already have Sarvkrit in `/Applications` from the DMG or the install script? Homebrew
refuses to overwrite an app it did not install, so adopt the existing copy instead:

```sh
brew install --cask --adopt sadana-psylief/tap/sarvkrit
```

Then, from there on:

```sh
brew upgrade --cask sarvkrit
```

## Why this tap, and not homebrew/cask

Sarvkrit is signed but **not notarized** — notarization requires a paid Apple Developer
account. `homebrew/cask` audits every cask with `gktool scan` and no longer accepts
un-notarized apps, so Sarvkrit could not live there even setting its notability rules
aside.

That has a consequence worth stating plainly. Homebrew quarantines everything it
downloads, and removed the `--no-quarantine` escape hatch in 5.1, so an un-notarized app
installed the ordinary way is stopped by Gatekeeper on first launch. This cask therefore
removes the quarantine attribute itself, in a `postflight_steps` block, and leans on the
pinned `sha256` to guarantee it installed the exact bytes that were published — the same
trade [the install script](https://sarvkrit.com/install) makes when it checks the
signature and the Team ID by hand.

It is **not** equivalent to notarization: it swaps Apple's trust root for a hash
published by the same repository that publishes the DMG. If you would rather have
Gatekeeper's own check, download the DMG from [sarvkrit.com](https://sarvkrit.com) and
use System Settings → Privacy & Security → Open Anyway on first launch.

Once there is a paid Apple Developer account and the DMG is notarized, the
`postflight_steps` block goes away and this becomes an ordinary cask. It is marked
`TODO(notarize)` for exactly that reason.

## Licence

The cask file here is MIT. Sarvkrit itself is
[PolyForm Shield 1.0.0](https://polyformproject.org/licenses/shield/1.0.0) —
source-available, not open source.
