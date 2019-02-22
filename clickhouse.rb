class Clickhouse < Formula
  desc "is an open-source column-oriented database management system."
  homepage "https://clickhouse.yandex/"
  url "https://github.com/yandex/ClickHouse/archive/v19.3.5-stable.zip"
  version "19.3.5"
  sha256 "b6694e81e4fedffa22db2a4beb2acef7b032d15454d515e01376603078d2381d"

  devel do
    url "https://github.com/yandex/ClickHouse/archive/v19.3.5-testing.zip"
    version "19.3.5"
    sha256 "22efdb44b55316f97f7e97c399705d1e19e58f39d36b4858a65ea491c5121f2d"
  end

  # bottle do
  #   root_url '
  #   sha256 "" => :high_sierra
  # end
  
  head "https://github.com/yandex/ClickHouse.git"

  depends_on "cmake" => :build
  depends_on "gcc@8" => :build

  depends_on "boost" => :build
  depends_on "icu4c" => :build
  depends_on "mysql@5.7" => :build
  depends_on "openssl" => :build
  depends_on "unixodbc" => :build
  depends_on "libtool" => :build
  depends_on "gettext" => :build
  depends_on "zlib" => :build
  depends_on "readline" => :recommended

  def install
    ENV["ENABLE_MONGODB"] = "0"
    ENV["CC"] = "#{Formula["gcc@8"].bin}/gcc-8"
    ENV["CXX"] = "#{Formula["gcc@8"].bin}/g++-8"
    
    inreplace "libs/libmysqlxx/cmake/find_mysqlclient.cmake", "/usr/local/opt/mysql/lib", "/usr/local/opt/mysql@5.7/lib"
    inreplace "libs/libmysqlxx/cmake/find_mysqlclient.cmake", "/usr/local/opt/mysql/include", "/usr/local/opt/mysql@5.7/include"

    cmake_args = %w[]
    cmake_args << "-DUSE_STATIC_LIBRARIES=0" if MacOS.version >= :sierra

    mkdir "build"
    cd "build" do
      system "cmake", "..", *cmake_args
      system "make"
      if MacOS.version >= :sierra
        lib.install Dir["#{buildpath}/build/dbms/*.dylib"]
        lib.install Dir["#{buildpath}/build/contrib/libzlib-ng/*.dylib"]
      end
      bin.install "#{buildpath}/build/dbms/src/Server/clickhouse"
      bin.install_symlink "clickhouse" => "clickhouse-server"
      bin.install_symlink "clickhouse" => "clickhouse-client"
    end

    mkdir "#{var}/clickhouse"

    inreplace "#{buildpath}/dbms/src/Server/config.xml" do |s|
      s.gsub! "/var/lib/clickhouse/", "#{var}/clickhouse/"
      s.gsub! "/var/log/clickhouse-server/", "#{var}/log/clickhouse/"
      s.gsub! "<!-- <max_open_files>262144</max_open_files> -->", "<max_open_files>262144</max_open_files>"
    end

    # Copy configuration files
    mkdir "#{etc}/clickhouse/"
    mkdir "#{etc}/clickhouse/config.d/"
    mkdir "#{etc}/clickhouse/users.d/"

    (etc/"clickhouse").install "#{buildpath}/dbms/src/Server/config.xml"
    (etc/"clickhouse").install "#{buildpath}/dbms/src/Server/users.xml"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/clickhouse-server</string>
            <string>--config-file</string>
            <string>#{etc}/clickhouse/config.xml</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    The configuration files are available at:
      #{etc}/clickhouse/
    The database itself will store data at:
      #{var}/clickhouse/
    If you're going to run the server, make sure to increase `maxfiles` limit:
      https://github.com/yandex/ClickHouse/blob/master/MacOS.md
  EOS
  end

  test do
    system "#{bin}/clickhouse-client", "--version"
  end
end
