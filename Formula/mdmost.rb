# Homebrew formula for mdmost. This repository is its own tap:
#
#   brew tap oetiker/mdmost https://github.com/oetiker/mdmost
#   brew install mdmost
#
# The version and the four sha256 lines are rewritten by .github/workflows/release.yml
# after the release artifacts exist. The trailing marker comments are what that
# rewrite matches on — do not remove them.
class Mdmost < Formula
  desc "Full-screen terminal pager for a single Markdown document"
  homepage "https://github.com/oetiker/mdmost"
  version "0.3.3"
  license "MIT"

  # Bottles exist for one reason: without one, Homebrew treats this formula as a source
  # build and refuses to install on a Mac whose Command Line Tools are older than its
  # macOS, even though nothing here is compiled. The block is rewritten by
  # .github/workflows/release.yml once a release's bottles exist, and the marker
  # comments are the range that rewrite replaces — do not remove them. Empty means no
  # bottle is published yet, which costs nothing but that check.
  #
  # One bottle per architecture is enough: on macOS, Homebrew falls back to a bottle
  # built for an *older* macOS of the same architecture (find_older_compatible_tag in
  # extend/os/mac/utils/bottles.rb), so these keep working on later releases. That
  # fallback only reaches upward, which is why the bottles are built on the oldest
  # runner image available for each architecture.
  # BOTTLE-START
  bottle do
    root_url "https://github.com/oetiker/mdmost/releases/download/v0.3.1"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "b17633cc5f534af4cb60ed4eb92791da21d08e7a70758ef80256e28bd27d8fc7"
    sha256 cellar: :any_skip_relocation, sequoia: "d16eae6b9407e979ac5b5c788abd8fb1d9fff83b65f352669a34b602a8d04baa"
  end
  # BOTTLE-END

  on_macos do
    on_arm do
      url "https://github.com/oetiker/mdmost/releases/download/v#{version}/mdmost-#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "e3d8bde92e986f2e36e8193645569da22d2c48c49d17932fd533603842060435" # mac-arm
    end
    on_intel do
      url "https://github.com/oetiker/mdmost/releases/download/v#{version}/mdmost-#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "0929e08491d1e3d8d68d389888ab76ea3a7e46525d57266ebdfcc41f2c242d13" # mac-x86
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/oetiker/mdmost/releases/download/v#{version}/mdmost-#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "cb7acee0d7d8c83a65471b9f19acc785690b826ecaeab73615f315db44f9a99b" # linux-x86
    end
    on_arm do
      url "https://github.com/oetiker/mdmost/releases/download/v#{version}/mdmost-#{version}-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2afd7066311c3edcd5dc32d889d7d0b6bf70d4b449ac9a0c8a27007217e2a6d6" # linux-arm
    end
  end

  def install
    bin.install "mdmost"
    man1.install "man/mdmost.1"
    # Terminal configuration fragments, as examples. Nothing loads them from here:
    # WezTerm and kitty each read one file owned by the user, so these are copied by
    # hand. See integrations/README.md, and mdmost(1) DEFAULT MARKDOWN VIEWER.
    pkgshare.install "integrations"
  end

  def caveats
    <<~EOS
      To open Markdown files with mdmost by clicking a file:// link in your
      terminal, copy the fragment for it out of:
        #{opt_pkgshare}/integrations
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mdmost --version")
    (testpath/"doc.md").write("# Title\n\nBody text.\n")
    assert_match "Body text", shell_output("#{bin}/mdmost --render-once --width 40 #{testpath}/doc.md")
  end
end
