# Homebrew formula for zazzle; written by macos/release/formula.sh on each release.
class Zazzle < Formula
  desc "Agent file tools: zazzle, its zazzled daemon, a C# code indexer, free-disk-space and fix-network"
  homepage "https://github.com/david-brandt-the-icelander/software-developers-toolbox"
  url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.6/zazzle-macos-universal.tar.gz"
  version "1.2.6"
  sha256 "82e4d417f29dc7823d345cb3944516f01ec70043034ce32d403c0ba47769ae67"
  license "Unlicense"

  bottle do
    root_url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.6"
    sha256 cellar: :any_skip_relocation, all: "81414f5773500f06791aadb02fef539d6b841854605ec95e2f3a57005b2a3880"
  end

  depends_on :macos

  def install
    bin.install "zazzle", "zazzled", "afs", "fix-network", "free-disk-space"
    (libexec/"indexer").install "zazzle-csharp-indexer-arm64.gz", "zazzle-csharp-indexer-x64.gz"
    (bin/"zazzle-csharp-indexer").write <<~SH
      #!/bin/sh
      echo "zazzle-csharp-indexer is not set up yet; run: brew postinstall zazzle" >&2
      exit 1
    SH
    chmod 0755, bin/"zazzle-csharp-indexer"
  end

  # Expand the C# indexer for this CPU over the placeholder, which brew linked before post-install ran.
  post_install_steps do
    run "/bin/sh",
        args:           ["-c", 'set -e; a=x64; [ "$(uname -m)" = arm64 ] && a=arm64; gunzip -c "$1/zazzle-csharp-indexer-$a.gz" > "$2.tmp"; chmod 755 "$2.tmp"; mv -f "$2.tmp" "$2"',
                         "sh", "{{libexec}}/indexer", "{{bin}}/zazzle-csharp-indexer"],
        writable_paths: ["zazzle-csharp-indexer", "zazzle-csharp-indexer.tmp"],
        writable_base:  :bin
  end

  test do
    assert_match "zazzle", shell_output("#{bin}/zazzle version")
    assert_match "zazzled", shell_output("#{bin}/zazzled --version")
    assert_match "fix-network", shell_output("#{bin}/fix-network --version")
    assert_match "free-disk-space", shell_output("#{bin}/free-disk-space --version")
    assert_match "agent-fs", shell_output("#{bin}/afs --version")
    assert_match "zazzle-csharp-indexer", shell_output("#{bin}/zazzle-csharp-indexer --version")
  end
end
