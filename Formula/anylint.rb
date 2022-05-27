class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/FlineDev/AnyLint"
  url "https://github.com/FlineDev/AnyLint.git", :tag => "0.10.0", :revision => "5a9c6d2289e1fc4e4f453c04d8a1ec891ea0797d"
  head "https://github.com/FlineDev/AnyLint.git"

  depends_on :xcode => ["12.5", :build]
  depends_on "swift-sh"

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system bin/"anylint", "-v"
  end
end
