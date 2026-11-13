# Homebrew formula for zazzle; written by macos/release/formula.sh on each release.
class Zazzle < Formula
  desc "Agent file tools: zazzle, its zazzled daemon, a C# code indexer, free-disk-space and fix-network"
  homepage "https://github.com/david-brandt-the-icelander/software-developers-toolbox"
  url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.1/zazzle-macos-universal.tar.gz"
  version "1.2.1"
  sha256 "e39c8d1aa773742d16cfbeced2f8fa0e857d717ec910b18a0a1f79ab9df358b1"
  license "Unlicense"

  bottle do
    root_url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.1"
    sha256 cellar: :any_skip_relocation, all: "a355d88e4513cb795e70c699e354031148203efa64cd55657887332dc2cf3c6d"
  end

  depends_on :macos

  def install
    bin.install "zazzle", "zazzled", "afs", "fix-network", "free-disk-space"
    (libexec/"indexer").install "zazzle-csharp-indexer-arm64.gz", "zazzle-csharp-indexer-x64.gz"
  end

  # Expand the C# indexer for this CPU (compressed to keep the download and the bottle small).
  def post_install
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    system "sh", "-c", 'gunzip -c "$1" > "$2" && chmod 755 "$2"', "sh",
           libexec/"indexer/zazzle-csharp-indexer-#{arch}.gz", bin/"zazzle-csharp-indexer"
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
