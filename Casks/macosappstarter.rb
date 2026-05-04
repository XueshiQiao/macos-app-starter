# DRAFT — this cask is a template only. Before publishing:
# 1. Pick a tap topology (see docs in macos-app-scaffold/skills/macos-app-scaffold-new/SKILL.md
#    Step 4a). Move this file to the chosen tap repo.
# 2. Replace the version + sha256 with values from a real release.
# 3. Update the livecheck strategy if you ship via Sparkle (see comments below).
cask "macosappstarter" do
  version "0.1.0"
  sha256 ""

  url "https://github.com/XueshiQiao/macos-app-starter/releases/download/v#{version}/MacOSAppStarter.dmg"
  name "MacOSAppStarter"
  desc "Production-ready macOS app scaffold demonstrating Sparkle, i18n, and CI/CD"
  homepage "https://github.com/XueshiQiao/macos-app-starter"

  # When you ship Sparkle releases (CI commits appcast.xml to main),
  # swap to the :sparkle strategy with the same URL Sparkle's SUFeedURL uses:
  #   livecheck do
  #     url "https://raw.githubusercontent.com/XueshiQiao/macos-app-starter/main/appcast.xml"
  #     strategy :sparkle
  #   end
  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true

  depends_on macos: ">= :sonoma"

  app "MacOSAppStarter.app"

  zap trash: [
    "~/Library/Preferences/dev.xueshi.macos-app-starter.plist",
    "~/Library/Application Support/MacOSAppStarter",
    "~/Library/Caches/dev.xueshi.macos-app-starter",
    "~/Library/HTTPStorages/dev.xueshi.macos-app-starter",
    "~/Library/Saved Application State/dev.xueshi.macos-app-starter.savedState",
    "~/Library/Logs/MacOSAppStarter.log",
  ]
end
