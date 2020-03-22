class Anylint < Formula
  desc "Lint anything by combining the power of Swift & regular expressions"
  homepage "https://github.com/Flinesoft/AnyLint"
  url "https://github.com/Flinesoft/AnyLint.git", :tag => "0.1.0", :revision => "25fec7dd29d86f0ef97fc2dddcd41d2576d9570c"
  head "https://github.com/Flinesoft/AnyLint.git"

  depends_on :xcode => ["11.3", :build]

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system bin/"anylint", "-v"
  end
end
