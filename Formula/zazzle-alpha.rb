# Homebrew formula for zazzle; written by release/formula.sh on each release.
class ZazzleAlpha < Formula
  desc "Agent tools behind one launcher: zazzle (and z), a C# indexer and macOS fixers"
  homepage "https://github.com/david-brandt-the-icelander/zazzle"
  url "https://github.com/david-brandt-the-icelander/zazzle/releases/download/v1.5.0-alpha.1/zazzle-macos-universal.tar.gz"
  version "1.5.0-alpha.1"
  sha256 "625955cc203136ed94c69020b224784602697fb83ad44336dbf2b30f474831b5"
  license "Unlicense"

  bottle do
    root_url "https://github.com/david-brandt-the-icelander/zazzle/releases/download/v1.5.0-alpha.1"
    sha256 cellar: :any_skip_relocation, all: "98cbd0c95efca3d41e4870d12ed73d1a9e8bc03ba7926e331734e0aedfa0469e"
  end

  depends_on :macos
  conflicts_with "zazzle", because: "both install the zazzle commands"

  # Only the launcher is linked; the tools stay in libexec/zazzle, where `zazzle TOOL` finds them.
  def install
    bin.install "bin/zazzle"
    (libexec/"zazzle").install "libexec/zazzle/daemon", "libexec/zazzle/zazz-script-runner", "libexec/zazzle/fix-network", "libexec/zazzle/free-disk-space", "libexec/zazzle/git-tools", "libexec/zazzle/git-tools-commit", "libexec/zazzle/git-tools-commit-message-editor", "libexec/zazzle/ai-agent-rules", "libexec/zazzle/cyberspace-generator"
    (libexec/"indexer").install "libexec/indexer/csharp-indexer-arm64.gz", "libexec/indexer/csharp-indexer-x64.gz"
  end

  # Expands the C# indexer for this CPU into libexec/zazzle, then gives zazzle the short name z: an earlier z
  # of zazzle's own (either channel) is replaced, and none is made when another program has bin/z (or zoxide or
  # z.sh is installed, or /usr/local/bin/z exists) or HOMEBREW_PREFIX/etc/zazzle/no-z asks for none.
  post_install_steps do
    run "/bin/sh",
        args:           ["-c", 'set -e; a=x64; [ "$(uname -m)" = arm64 ] && a=arm64; gunzip -c "$1/csharp-indexer-$a.gz" > "$2.tmp"; chmod 755 "$2.tmp"; mv -f "$2.tmp" "$2"',
                         "sh", "{{libexec}}/indexer", "{{libexec}}/zazzle/csharp-indexer"],
        writable_paths: ["zazzle/csharp-indexer", "zazzle/csharp-indexer.tmp"],
        writable_base:  :libexec
    remove "bin/z", base: :homebrew_prefix, symlink_target_contains: "/opt/zazzle"
    unless_path_exists "etc/zazzle/no-z", base: :homebrew_prefix do
      unless_path_exists "bin/z", base: :homebrew_prefix do
        unless_path_exists "bin/zoxide", base: :homebrew_prefix do
          unless_path_exists "etc/profile.d/z.sh", base: :homebrew_prefix do
            unless_path_exists "/usr/local/bin/z" do
              symlink "bin/zazzle", "bin/z", source_base: :opt_prefix, target_base: :homebrew_prefix,
                                             overwrite: true, remove_on_uninstall: true
            end
          end
        end
      end
    end
  end

  # A daemon started by an older version keeps answering until it is replaced; say how after every install.
  def caveats
    <<~EOS
      Every tool runs through the launcher: zazzle TOOL ARGS (for example: zazzle daemon restart).
      zazzle --version reports the running daemon's version. If it is older than 1.5.0-alpha.1, replace it with:
        zazzle daemon restart
      z is linked to zazzle unless another z was found. To keep z for something else:
        mkdir -p #{HOMEBREW_PREFIX}/etc/zazzle && touch #{HOMEBREW_PREFIX}/etc/zazzle/no-z && brew postinstall zazzle-alpha
    EOS
  end

  test do
    assert_match "zazzle", shell_output("#{bin}/zazzle version")
    assert_match "daemon", shell_output("#{bin}/zazzle daemon --version")
    assert_match "zazz", shell_output("#{bin}/zazzle zazz help")
    assert_match "zazz-script-runner", shell_output("#{libexec}/zazzle/zazz-script-runner version")
    assert_match "fix-network", shell_output("#{bin}/zazzle fix-network --version")
    assert_match "free-disk-space", shell_output("#{bin}/zazzle free-disk-space --version")
    assert_match "git-tools", shell_output("#{bin}/zazzle git-tools --version")
    assert_match "ai-agent-rules", shell_output("#{bin}/zazzle ai-agent-rules --version")
    assert_match "csharp-indexer", shell_output("#{bin}/zazzle csharp-indexer --version")
    assert_match "cyberspace-generator", shell_output("#{bin}/zazzle cyberspace-generator --version")
  end
end
