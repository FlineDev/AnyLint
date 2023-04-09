class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/FlineDev/AnyLint"
  url "https://github.com/FlineDev/AnyLint.git", :tag => "0.11.0", :revision => "3c1bdfc45fe434cb4e3ea7814f49db16f3eeccf2"
  head "https://github.com/FlineDev/AnyLint.git"

  depends_on :xcode => ["14.0", :build]
  depends_on "swift-sh"

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system bin/"anylint", "-v"
  end
end
