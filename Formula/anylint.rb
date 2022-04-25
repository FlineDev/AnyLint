class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/FlineDev/AnyLint"
  url "https://github.com/FlineDev/AnyLint.git", :tag => "0.9.2", :revision => "a696a4d40a3ede9daa07d7a381101a1e4e6efc46"
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
