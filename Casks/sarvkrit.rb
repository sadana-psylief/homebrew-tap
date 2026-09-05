cask "sarvkrit" do
  version "1.1.0"
  sha256 "11fa22bef4633299a8fe137fe4422dc80e3a51be3122b300fbbfb3b67aaf5f76"

  # Pinned to the tag, not releases/latest/download/. `latest` moves the moment the next release
  # is cut, and a moving URL behind a fixed sha256 is a checksum mismatch waiting to happen.
  # scripts/update-tap.sh in the app repo rewrites both lines above on every release.
  url "https://github.com/sadana-psylief/Sarvkrit/releases/download/v#{version}/Sarvkrit.dmg"
  name "Sarvkrit"
  desc "Menu-bar utility that fixes the things macOS does differently than you'd expect"
  homepage "https://sarvkrit.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The app's real floor is macOS 14.4 — Core Audio process taps, which per-app volume needs, do
  # not exist before it. A cask can only name whole releases, so this is the closest it can say;
  # LSMinimumSystemVersion in the bundle and the sw_vers check in sarvkrit.com/install enforce
  # the exact version.
  depends_on macos: ">= :sonoma"

  app "Sarvkrit.app"

  # TODO(notarize): delete this whole block once the DMG is notarized.
  #
  # Homebrew quarantines everything it downloads, and --no-quarantine was removed in Homebrew 5.1.
  # Sarvkrit is signed but not notarized (notarization needs a paid Apple Developer account), so
  # without this every brew install and every brew upgrade lands the user in System Settings →
  # Privacy & Security → Open Anyway — exactly the wall sarvkrit.com/install exists to avoid.
  #
  # What makes removing it defensible is the sha256 above: it pins the precise bytes of the DMG,
  # which is the same trade the install script makes when it verifies the signature and the team
  # itself. It is NOT equivalent to notarization — it swaps Apple's trust root for this file's
  # hash, published by the same repo that publishes the DMG.
  #
  # -r is load-bearing rather than tidiness: Homebrew marks every file in the bundle, not just the
  # top level. It is also what makes the default must_succeed correct — `xattr -dr` exits 0 when
  # the attribute is already absent, so `brew install --adopt` over a copy installed by the curl
  # script (which never quarantines anything) does not abort here. Plain `xattr -d` exits 1 in
  # that case; only the recursive form is forgiving.
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/Sarvkrit.app"]
  end

  # Info.plist sets LSMultipleInstancesProhibited, and a running bundle cannot be replaced under
  # itself, so quit before upgrading or uninstalling. The launch agent is the six-hourly update
  # check the app registers through SMAppService.
  uninstall quit:      "ai.psylief.sarvkrit",
            launchctl: "ai.psylief.sarvkrit.updatecheck"

  zap trash: [
    "~/Library/Application Support/Sarvkrit",
    "~/Library/Caches/ai.psylief.sarvkrit",
    "~/Library/HTTPStorages/ai.psylief.sarvkrit",
    "~/Library/Preferences/ai.psylief.sarvkrit.plist",
  ]
end
