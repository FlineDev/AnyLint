class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/Flinesoft/AnyLint"
  url "https://github.com/Flinesoft/AnyLint.git", :tag => "0.6.1", :revision => "25265e1c9a033ea5869744affac94ff55676bbaf"
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
