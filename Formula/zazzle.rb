# Homebrew formula for zazzle; written by macos/release/formula.sh on each release.
class Zazzle < Formula
  desc "Agent file tools: zazzle, its zazzled daemon, a C# code indexer, free-disk-space and fix-network"
  homepage "https://github.com/david-brandt-the-icelander/software-developers-toolbox"
  url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.0/zazzle-macos-universal.tar.gz"
  version "1.2.0"
  sha256 "a0aa9bd841bcf8df542aaea0e826e4dc92f1e215319788798aee84cdd1db2b38"
  license "Unlicense"

  bottle do
    root_url "https://github.com/david-brandt-the-icelander/software-developers-toolbox/releases/download/v1.2.0"
    sha256 cellar: :any_skip_relocation, all: "d51cd51241422656c92dfff7248ddfdf12e0d6ecac435316bb545a06e8106262"
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
