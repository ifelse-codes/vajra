class Vajra < Formula
  desc "One CLI that guides any AI coding agent through your project, step by step"
  homepage "https://github.com/ifelse-codes/vajra"
  license "Apache-2.0"
  version "0.1.0"

  on_macos do
    on_arm do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-aarch64-apple-darwin.tar.gz"
      sha256 "b62572929b70233d117486ee75455f41347460b4381fb107a03acc83a5174c3e"
    end

    on_intel do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-x86_64-apple-darwin.tar.gz"
      sha256 "dc20a0ab9ceb32fa467148db81e555654416a052dbcfaf67c226dd1cf56af2ef"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/ifelse-codes/vajra/releases/download/v#{version}/vajra-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f4b69eedba5ad2a4f529a81465fab3c75e349f0016d4830e1170a7b7fabc05ac"
    end
  end

  def install
    bin.install "vajra"
  end

  test do
    assert_match "vajra", shell_output("#{bin}/vajra --help")
  end
end
