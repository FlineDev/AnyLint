class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/FlineDev/AnyLint"
  url "https://github.com/FlineDev/AnyLint.git", :tag => "0.8.4", :revision => "d8c2491332c5256fd1be7668e760517d04e8c257"
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
