# Homebrew formula for zazzle; written by macos/release/formula.sh on each release.
class Zazzle < Formula
  desc "Agent tools: zazzle, zazzled, a C# indexer, cyberspace-generator and macOS fixers"
  homepage "https://github.com/david-brandt-the-icelander/software-developers-toolbox"
  url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.15/zazzle-macos-universal.tar.gz"
  version "1.2.15"
  sha256 "cab350e29999ed359446c7a31d549fc2000afe4c8cf84842d2f41b9bbc37d5ba"
  license "Unlicense"

  bottle do
    root_url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.15"
    sha256 cellar: :any_skip_relocation, all: "e5fe503a235f9ba6d7dc6676474859d8a4cb2648f279b058ef76a7ce0ed89ba6"
  end

  depends_on :macos

  def install
    bin.install "zazzle", "zazz", "zazzled", "zazz-worker", "afs", "fix-network", "free-disk-space", "cyberspace-generator"
    bin.install_symlink "zazzle" => "z"
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
    assert_match "zazzle", shell_output("#{bin}/z version")
    assert_match "zazzled", shell_output("#{bin}/zazzled --version")
    assert_match "zazz", shell_output("#{bin}/zazz help")
    assert_match "zazz-worker", shell_output("#{bin}/zazz-worker version")
    assert_match "fix-network", shell_output("#{bin}/fix-network --version")
    assert_match "free-disk-space", shell_output("#{bin}/free-disk-space --version")
    assert_match "agent-fs", shell_output("#{bin}/afs --version")
    assert_match "zazzle-csharp-indexer", shell_output("#{bin}/zazzle-csharp-indexer --version")
    assert_match "cyberspace-generator", shell_output("#{bin}/cyberspace-generator --version")
  end
end
