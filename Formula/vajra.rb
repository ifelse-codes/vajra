class Vajra < Formula
  desc "One CLI that guides any AI coding agent through your project, step by step"
  homepage "https://github.com/ifelse-codes/vajra"
  license "Apache-2.0"
  version "0.2.0"

  on_macos do
    on_arm do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-aarch64-apple-darwin.tar.gz"
      sha256 "a1a8247535b7bd214345f86f19bce78582b25a67a240ff210277b74eb4c9bd08"
    end

    on_intel do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-x86_64-apple-darwin.tar.gz"
      sha256 "b1ca81a4b3a8800bd103cfcc153c7fa7263a26ec63cf13c49cc28d4a165aba5a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "1c56af2b59fe836502c76e9b812a66690d4a2ce63ff6fef292be968cf189e452"
    end
  end

  def install
    bin.install "vajra"
  end

  test do
    assert_match "vajra", shell_output("#{bin}/vajra --help")
  end
end
