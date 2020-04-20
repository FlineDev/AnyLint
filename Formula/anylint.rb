class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/Flinesoft/AnyLint"
  url "https://github.com/Flinesoft/AnyLint.git", :tag => "0.3.0", :revision => "f95b6d6ad58767a87aafa636410f8010e8dcbd3c"
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
