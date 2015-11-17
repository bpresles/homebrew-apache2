homebrew-apache2
----------------

[homebrew][h] + [Apache 2.4][a]

[h]: https://github.com/mxcl/homebrew
[a]: https://httpd.apache.org/

**Installation**

    brew tap bpresles/homebrew-apache2
    brew install bpresles/apache2/httpd24

**Configuration**

You must configure a MPM module on /usr/local/etc/apache2/httpd.conf before using this apache build.
To do so, add the following line to the config file:

For prefork MPM:

LoadModule mpm_prefork_module lib/apache2/modules/mod_mpm_prefork.so

For worker MPM:

LoadModule mpm_worker_module lib/apache2/modules/mod_mpm_worker.so

For event MPM:

LoadModule mpm_event_module lib/apache2/modules/mod_mpm_event.so

**Using PHP**

To use PHP with this apache formula, you must install (or reinstall) php55 with --homebrew-apxs option:

    brew install homebrew/php/php55 --with-homebrew-apxs

or

    brew reinstall homebrew/php/php55 --with-homebrew-apxs	

Also if you use a multithreaded mpm module in Apache, don't forget to build php55 with --with-thread-safety option:

    brew install homebrew/php/php55 --with-homebrew-apxs --with-thread-safety

or

    brew reinstall homebrew/php/php55 --with-homebrew-apxs --with-thread-safety
