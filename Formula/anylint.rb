class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/Flinesoft/AnyLint"
  url "https://github.com/Flinesoft/AnyLint.git", :tag => "0.5.0", :revision => "3ef3603e2ae44d8cc8a64a99a7b9af0440aa1b3e"
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
