use inc::Module::Install;
name 'test';
version 0.01;
license 'perl';

clib_header 'foo.h';

makemaker_args(
    INSTALLARCHLIB    => './inst/',
    INSTALLSITEARCH   => './inst/',
    INSTALLVENDORARCH => './inst/',
);

WriteMakefile();

