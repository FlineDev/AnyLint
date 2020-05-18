class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/Flinesoft/AnyLint"
  url "https://github.com/Flinesoft/AnyLint.git", :tag => "0.8.0", :revision => "0a7cde6513c3b9404b4b425e372a27fa2cae12dd"
  head "https://github.com/Flinesoft/AnyLint.git"

  depends_on :xcode => ["11.4", :build]
  depends_on "swift-sh"

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system bin/"anylint", "-v"
  end
end
