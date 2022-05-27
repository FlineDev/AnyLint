class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/FlineDev/AnyLint"
  url "https://github.com/FlineDev/AnyLint.git", :tag => "0.10.1", :revision => "84ee29f12ae7297e917c9a3339dfb25e5dca6dd5"
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
