class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/FlineDev/AnyLint"
  url "https://github.com/FlineDev/AnyLint.git", :tag => "0.8.5", :revision => "1078228fb2251d9efa369768530638790587d4eb"
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
