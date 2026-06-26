class Vajra < Formula
  desc "One CLI that guides any AI coding agent through your project, step by step"
  homepage "https://github.com/ifelse-codes/vajra"
  license "Apache-2.0"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-aarch64-apple-darwin.tar.gz"
      sha256 "PLACEHOLDER"
    end

    on_intel do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-x86_64-apple-darwin.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "vajra"
  end

  test do
    assert_match "vajra", shell_output("#{bin}/vajra --help")
  end
end
