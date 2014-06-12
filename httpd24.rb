require 'formula'

class Httpd24 < Formula

homepage 'https://httpd.apache.org/'
  url 'http://mirror.cc.columbia.edu/pub/software/apache/httpd/httpd-2.4.9.tar.bz2'
  sha1 '646aedbf59519e914c424b3a85d846bf189be3f4'

  skip_clean ['bin', 'sbin', 'logs']

  depends_on 'pcre'
  depends_on 'lua' => :optional

  # Apache 2.4 no longer bundles apr or apr-util so we have to fetch
  # it manually for each build
  def fetch_apr
    ["apr-1.5.1", "apr-util-1.5.3"].each do |tb|
      curl "-s", "-o", "#{tb}.tar.gz", "https://www.apache.org/dist/apr/#{tb}.tar.gz"
      system "tar -xzf #{tb}.tar.gz"
      dir = tb.rpartition('-')[0]
      FileUtils.mv(tb, "srclib/#{dir}")
    end
  end

  def install
    fetch_apr

    # install custom layout
    File.open('config.layout', 'w') { |f| f.write(apache_layout) };

    args = [
      "--prefix=#{prefix}",
      "--mandir=#{man}",
      "--disable-debug",
      "--disable-dependency-tracking",
      "--with-included-apr",
      "--enable-mpms-shared=all",
      "--enable-mods-shared=all",
      "--with-pcre=#{Formula.factory('pcre').prefix}",
      "--enable-layout=Homebrew"
    ]
    args << "--enable-lua" if build.with? 'lua'

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
