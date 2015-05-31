require 'formula'

CRYSTAL_VERSION = "0.7.2"
CRYSTAL_SHA = "ad7cb7b7e46f7f9ed033ec3cdbb02ca671fc97ed"

class Crystal < Formula
  homepage 'http://crystal-lang.org/'
  version CRYSTAL_VERSION

  stable do
    url "https://github.com/manastech/crystal/releases/download/#{CRYSTAL_VERSION}/crystal-#{CRYSTAL_VERSION}-1-darwin-x86_64.tar.gz"
    sha1 CRYSTAL_SHA
  end

  # head do
  #   url 'http://github.com/manastech/crystal.git'

  #   resource 'latest' do
  #     url 'http://crystal-lang.s3.amazonaws.com/crystal-darwin-latest.tar.gz'
  #   end
  # end

  depends_on "llvm" => :optional
  depends_on "libpcl" => :recommended
  depends_on "openssl"
  depends_on "pkg-config"

  def install
    # if build.head?
    #   resource('latest').stage do
    #     (prefix/"deps").install "bin/crystal-exe" => "crystal"
    #   end

    #   script_root = %Q(INSTALL_DIR="#{prefix}")
    # end

    script_root = %Q(INSTALL_DIR="#{prefix}")
    openssl_libdir = %Q(LIBRARY_PATH="#{Formula['openssl'].opt_lib}")
    inreplace('bin/crystal') do |s|
      s.gsub! /INSTALL_DIR=.+/, [script_root, openssl_libdir].join("\n")
    end

    if build.with?('llvm') || Formula["llvm"].installed?
      inreplace('bin/crystal') do |s|
        if s =~ /export PATH="(.*)"/
          llvm_path = Formula["llvm"].opt_prefix
          s.gsub! /export PATH="(.*)"/, %(export PATH="#{llvm_path}/bin:#{$1}")
        end
      end
    end

    prefix.install Dir["*"]
  end

  def post_install
    resource('latest').clear_cache if build.head?
  end
end
