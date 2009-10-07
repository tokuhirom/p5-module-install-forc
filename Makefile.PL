use inc::Module::Install;

name 'Module-Install-ForC';
all_from 'lib/Module/Install/ForC.pm';
readme_from('lib/Module/Install/ForC.pm');

requires 'Module::Install';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
recursive_author_tests('xt');

if (-d '.git') { # author
    `rm -rf t/*/Makefile t/*/inc t/*/main t/*/*.gz t/*/*.o t/*/local t/*/Makefile.bak t/*/*.bak t/*/*.a t/*/*.so`;
}

build_requires 'Test::More';
auto_include;
WriteAll;
