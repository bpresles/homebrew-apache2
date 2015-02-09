require 'formula'

class Httpd24 < Formula

homepage 'https://httpd.apache.org/'
  url 'http://mirror.cc.columbia.edu/pub/software/apache/httpd/httpd-2.4.12.tar.bz2'
  sha1 'bc4681bfd63accec8d82d3cc440fbc8264ce0f17'

  skip_clean ['bin', 'sbin', 'logs']

  depends_on 'apr-util'
  depends_on 'pcre'
  depends_on "openssl"
  depends_on 'lua' => :optional
  depends_on "homebrew/dupes/zlib"

  def install

    # install custom layout
    File.open('config.layout', 'w') { |f| f.write(apache_layout) };

    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--enable-mpms-shared=all",
      "--enable-mods-shared=all",
      "--with-pcre=#{Formula.factory('pcre').prefix}",
      "--enable-layout=Homebrew"
      "--enable-ssl"
    ]
    args << "--enable-lua" if build.with? 'lua'
    args << "--with-apr=#{Formula["apr"].opt_prefix}"
    args << "--with-apr-util=#{Formula["apr-util"].opt_prefix}"
    args << "--with-z=#{Formula['zlib'].opt_prefix}"
    args << "--with-ssl=/usr"

    system './configure', *args
    system "make"
    system "make install"

    (var+"log/apache2").mkpath
    (var+"run/apache2").mkpath
  end

  def apache_layout
    return <<-EOS.undent
      <Layout Homebrew>
          prefix:        #{prefix}
          exec_prefix:   ${prefix}
          bindir:        ${exec_prefix}/bin
          sbindir:       ${exec_prefix}/bin
          libdir:        ${exec_prefix}/lib
          libexecdir:    #{lib}/apache2/modules
          mandir:        #{man}
          sysconfdir:    #{etc}/apache2
          datadir:       ${prefix}
          installbuilddir: ${datadir}/build
          errordir:      #{var}/apache2/error
          iconsdir:      #{var}/apache2/icons
          htdocsdir:     #{var}/apache2/htdocs
          manualdir:     #{doc}/manual
          cgidir:        #{var}/apache2/cgi-bin
          includedir:    ${prefix}/include/apache2
          localstatedir: #{var}/apache2
          runtimedir:    #{var}/run/apache2
          logfiledir:    #{var}/log/apache2
          proxycachedir: ${localstatedir}/proxy
      </Layout>
      EOS
  end

  plist_options :startup => true

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/bin/apachectl</string>
        <string>start</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end
end
