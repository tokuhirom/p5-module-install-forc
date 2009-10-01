use inc::Module::Install;
name 'Module-Install-ForC';
all_from 'lib/Module/Install/ForC.pm';
readme_from 'lib/Module/Install/ForC.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
