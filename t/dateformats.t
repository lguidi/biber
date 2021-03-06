# -*- cperl -*-
use strict;
use warnings;
use utf8;
no warnings 'utf8';

use Test::More tests => 41;
use Test::Differences;
unified_diff;

use Biber;
use Biber::Output::bbl;
use Biber::Utils;
use Log::Log4perl;
chdir("t/tdata");

# Set up Biber object
my $biber = Biber->new(noconf => 1);
my $LEVEL = 'ERROR';
my $l4pconf = qq|
    log4perl.category.main                             = $LEVEL, Screen
    log4perl.category.screen                           = $LEVEL, Screen
    log4perl.appender.Screen                           = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.utf8                      = 1
    log4perl.appender.Screen.Threshold                 = $LEVEL
    log4perl.appender.Screen.stderr                    = 0
    log4perl.appender.Screen.layout                    = Log::Log4perl::Layout::SimpleLayout
|;
Log::Log4perl->init(\$l4pconf);

$biber->parse_ctrlfile('dateformats.bcf');
$biber->set_output_obj(Biber::Output::bbl->new());

# Options - we could set these in the control file but it's nice to see what we're
# relying on here for tests

# Biber options
Biber::Config->setoption('sortlocale', 'en_GB.UTF-8');
Biber::Config->setoption('validate_datamodel', 1);

# Biblatex options
Biber::Config->setblxoption('labeldatespec', [ {content => 'date', type => 'field'} ]);
Biber::Config->setblxoption('julian', 1);
Biber::Config->setblxoption('julianstart', '0001-01-01');

# Now generate the information
$biber->prepare;
my $out = $biber->get_output_obj;
my $section = $biber->sections->get_section(0);
my $main = $biber->sortlists->get_list(0, 'nty/global/', 'entry', 'nty', 'global', '');
my $bibentries = $section->bibentries;
my $l1 = [ "Entry 'L1' (dateformats.bib): Invalid format '1985-1030' of date field 'origdate' - ignoring",
           "Entry 'L1' (dateformats.bib): Invalid format '1.5.1998' of date field 'urldate' - ignoring" ];
my $l2 = [ "Entry 'L2' (dateformats.bib): Invalid format '1995-1230' of date field 'origdate' - ignoring" ];
my $l3 = [ "Entry 'L3' (dateformats.bib): Invalid format '1.5.1988' of date field 'urldate' - ignoring" ];
my $l4 = [ "Entry 'L4' (dateformats.bib): Invalid format '1995-1-04' of date field 'date' - ignoring",
           "Datamodel: Entry 'L4' (dateformats.bib): Missing mandatory field - one of 'date, year' must be defined" ];
my $l5 = [ "Entry 'L5' (dateformats.bib): Invalid format '1995-10-4' of date field 'date' - ignoring",
           "Datamodel: Entry 'L5' (dateformats.bib): Missing mandatory field - one of 'date, year' must be defined" ];
my $l6 = [ "Entry 'L6' (dateformats.bib): Invalid format '1996-13-03' of date field 'date' - ignoring",
           "Datamodel: Entry 'L6' (dateformats.bib): Missing mandatory field - one of 'date, year' must be defined"];
my $l7 = [ "Entry 'L7' (dateformats.bib): Invalid format '1996-10-35' of date field 'eventdate' - ignoring" ];
my $l11 = [ "Overwriting field 'year' with year value from field 'date' for entry 'L11'"];
my $l12 = [ "Overwriting field 'month' with month value from field 'date' for entry 'L12'" ];

my $l13c = q|    \entry{L13}{book}{}
      \name{author}{2}{}{%
        {{hash=bd051a2f7a5f377e3a62581b0e0f8577}{%
           family={Doe},
           familyi={D\bibinitperiod},
           given={John},
           giveni={J\bibinitperiod}}}%
        {{hash=df9bf04cd41245e6d23ad7543e7fd90d}{%
           family={Abrahams},
           familyi={A\bibinitperiod},
           given={Albert},
           giveni={A\bibinitperiod}}}%
      }
      \list{publisher}{1}{%
        {Oxford}%
      }
      \strng{namehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{fullhash}{8c77336299b25bdada7bf8038f46722f}
      \strng{authornamehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{authorfullhash}{8c77336299b25bdada7bf8038f46722f}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{labeldatesource}{}
      \field{labelnamesource}{author}
      \field{labeltitlesource}{title}
      \field{day}{1}
      \field{endyear}{}
      \field{month}{1}
      \field{title}{Title 2}
      \field{year}{1996}
      \field{dateera}{ce}
    \endentry
|;

my $l14 = q|    \entry{L14}{book}{}
      \name{author}{2}{}{%
        {{hash=bd051a2f7a5f377e3a62581b0e0f8577}{%
           family={Doe},
           familyi={D\bibinitperiod},
           given={John},
           giveni={J\bibinitperiod}}}%
        {{hash=df9bf04cd41245e6d23ad7543e7fd90d}{%
           family={Abrahams},
           familyi={A\bibinitperiod},
           given={Albert},
           giveni={A\bibinitperiod}}}%
      }
      \list{publisher}{1}{%
        {Oxford}%
      }
      \strng{namehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{fullhash}{8c77336299b25bdada7bf8038f46722f}
      \strng{authornamehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{authorfullhash}{8c77336299b25bdada7bf8038f46722f}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{extrayear}{3}
      \field{labeldatesource}{}
      \field{labelnamesource}{author}
      \field{labeltitlesource}{title}
      \field{day}{10}
      \field{endday}{12}
      \field{endmonth}{12}
      \field{endyear}{1996}
      \field{month}{12}
      \field{title}{Title 2}
      \field{year}{1996}
      \field{dateera}{ce}
      \field{enddateera}{ce}
    \endentry
|;

my $l15 = q|    \entry{L15}{book}{}
      \name{author}{2}{}{%
        {{hash=bd051a2f7a5f377e3a62581b0e0f8577}{%
           family={Doe},
           familyi={D\bibinitperiod},
           given={John},
           giveni={J\bibinitperiod}}}%
        {{hash=df9bf04cd41245e6d23ad7543e7fd90d}{%
           family={Abrahams},
           familyi={A\bibinitperiod},
           given={Albert},
           giveni={A\bibinitperiod}}}%
      }
      \list{publisher}{1}{%
        {Oxford}%
      }
      \strng{namehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{fullhash}{8c77336299b25bdada7bf8038f46722f}
      \strng{authornamehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{authorfullhash}{8c77336299b25bdada7bf8038f46722f}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{extrayear}{4}
      \field{labelnamesource}{author}
      \field{labeltitlesource}{title}
      \field{title}{Title 2}
      \warn{\item Datamodel: Entry 'L15' (dateformats.bib): Missing mandatory field - one of 'date, year' must be defined}
    \endentry
|;

my $l16 = q|    \entry{L16}{proceedings}{}
      \name{editor}{2}{}{%
        {{hash=bd051a2f7a5f377e3a62581b0e0f8577}{%
           family={Doe},
           familyi={D\bibinitperiod},
           given={John},
           giveni={J\bibinitperiod}}}%
        {{hash=df9bf04cd41245e6d23ad7543e7fd90d}{%
           family={Abrahams},
           familyi={A\bibinitperiod},
           given={Albert},
           giveni={A\bibinitperiod}}}%
      }
      \list{publisher}{1}{%
        {Oxford}%
      }
      \strng{namehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{fullhash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editornamehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editorfullhash}{8c77336299b25bdada7bf8038f46722f}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{extrayear}{1}
      \field{labeldatesource}{event}
      \field{labelnamesource}{editor}
      \field{labeltitlesource}{title}
      \field{eventday}{1}
      \field{eventmonth}{1}
      \field{eventyear}{1996}
      \field{title}{Title 2}
      \field{eventdateera}{ce}
      \warn{\item Datamodel: Entry 'L16' (dateformats.bib): Missing mandatory field - one of 'date, year' must be defined}
    \endentry
|;

my $l17 = q|    \entry{L17}{proceedings}{}
      \name{editor}{2}{}{%
        {{hash=bd051a2f7a5f377e3a62581b0e0f8577}{%
           family={Doe},
           familyi={D\bibinitperiod},
           given={John},
           giveni={J\bibinitperiod}}}%
        {{hash=df9bf04cd41245e6d23ad7543e7fd90d}{%
           family={Abrahams},
           familyi={A\bibinitperiod},
           given={Albert},
           giveni={A\bibinitperiod}}}%
      }
      \list{publisher}{1}{%
        {Oxford}%
      }
      \strng{namehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{fullhash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editornamehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editorfullhash}{8c77336299b25bdada7bf8038f46722f}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{extrayear}{5}
      \field{labeldatesource}{}
      \field{labelnamesource}{editor}
      \field{labeltitlesource}{title}
      \field{day}{10}
      \field{endday}{12}
      \field{endmonth}{12}
      \field{endyear}{1996}
      \field{eventday}{10}
      \field{eventendday}{12}
      \field{eventendmonth}{12}
      \field{eventendyear}{2004}
      \field{eventmonth}{12}
      \field{eventyear}{1998}
      \field{month}{12}
      \field{origday}{10}
      \field{origendday}{12}
      \field{origendmonth}{12}
      \field{origendyear}{1998}
      \field{origmonth}{12}
      \field{origyear}{1998}
      \field{pubstate}{inpress}
      \field{title}{Title 2}
      \field{year}{1996}
      \field{dateera}{ce}
      \field{enddateera}{ce}
      \field{eventdateera}{ce}
      \field{eventenddateera}{ce}
      \field{origdateera}{ce}
      \field{origenddateera}{ce}
    \endentry
|;

my $l17c = q|    \entry{L17}{proceedings}{}
      \name{editor}{2}{}{%
        {{hash=bd051a2f7a5f377e3a62581b0e0f8577}{%
           family={Doe},
           familyi={D\bibinitperiod},
           given={John},
           giveni={J\bibinitperiod}}}%
        {{hash=df9bf04cd41245e6d23ad7543e7fd90d}{%
           family={Abrahams},
           familyi={A\bibinitperiod},
           given={Albert},
           giveni={A\bibinitperiod}}}%
      }
      \list{publisher}{1}{%
        {Oxford}%
      }
      \strng{namehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{fullhash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editornamehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editorfullhash}{8c77336299b25bdada7bf8038f46722f}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{labeldatesource}{orig}
      \field{labelnamesource}{editor}
      \field{labeltitlesource}{title}
      \field{day}{10}
      \field{endday}{12}
      \field{endmonth}{12}
      \field{endyear}{1996}
      \field{eventday}{10}
      \field{eventendday}{12}
      \field{eventendmonth}{12}
      \field{eventendyear}{2004}
      \field{eventmonth}{12}
      \field{eventyear}{1998}
      \field{month}{12}
      \field{origday}{10}
      \field{origendday}{12}
      \field{origendmonth}{12}
      \field{origendyear}{1998}
      \field{origmonth}{12}
      \field{origyear}{1998}
      \field{pubstate}{inpress}
      \field{title}{Title 2}
      \field{year}{1996}
      \field{dateera}{ce}
      \field{enddateera}{ce}
      \field{eventdateera}{ce}
      \field{eventenddateera}{ce}
      \field{origdateera}{ce}
      \field{origenddateera}{ce}
    \endentry
|;

my $l17e = q|    \entry{L17}{proceedings}{}
      \name{editor}{2}{}{%
        {{hash=bd051a2f7a5f377e3a62581b0e0f8577}{%
           family={Doe},
           familyi={D\bibinitperiod},
           given={John},
           giveni={J\bibinitperiod}}}%
        {{hash=df9bf04cd41245e6d23ad7543e7fd90d}{%
           family={Abrahams},
           familyi={A\bibinitperiod},
           given={Albert},
           giveni={A\bibinitperiod}}}%
      }
      \list{publisher}{1}{%
        {Oxford}%
      }
      \strng{namehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{fullhash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editornamehash}{8c77336299b25bdada7bf8038f46722f}
      \strng{editorfullhash}{8c77336299b25bdada7bf8038f46722f}
      \field{sortinit}{D}
      \field{sortinithash}{78f7c4753a2004675f316a80bdb31742}
      \field{labeldatesource}{event}
      \field{labelnamesource}{editor}
      \field{labeltitlesource}{title}
      \field{day}{10}
      \field{endday}{12}
      \field{endmonth}{12}
      \field{endyear}{1996}
      \field{eventday}{10}
      \field{eventendday}{12}
      \field{eventendmonth}{12}
      \field{eventendyear}{2004}
      \field{eventmonth}{12}
      \field{eventyear}{1998}
      \field{month}{12}
      \field{origday}{10}
      \field{origendday}{12}
      \field{origendmonth}{12}
      \field{origendyear}{1998}
      \field{origmonth}{12}
      \field{origyear}{1998}
      \field{pubstate}{inpress}
      \field{title}{Title 2}
      \field{year}{1996}
      \field{dateera}{ce}
      \field{enddateera}{ce}
      \field{eventdateera}{ce}
      \field{eventenddateera}{ce}
      \field{origdateera}{ce}
      \field{origenddateera}{ce}
    \endentry
|;

is_deeply($bibentries->entry('L1')->get_field('warnings'), $l1, 'Date values test 1' ) ;
ok(is_undef($bibentries->entry('L1')->get_field('origyear')), 'Date values test 1a - ORIGYEAR undef since ORIGDATE is bad' ) ;
ok(is_undef($bibentries->entry('L1')->get_field('urlyear')), 'Date values test 1b - URLYEAR undef since URLDATE is bad' ) ;
is_deeply($bibentries->entry('L2')->get_field('warnings'), $l2, 'Date values test 2' ) ;
is_deeply($bibentries->entry('L3')->get_field('warnings'), $l3, 'Date values test 3' ) ;
is_deeply($bibentries->entry('L4')->get_field('warnings'), $l4, 'Date values test 4' ) ;
is_deeply($bibentries->entry('L5')->get_field('warnings'), $l5, 'Date values test 5' ) ;
is_deeply($bibentries->entry('L6')->get_field('warnings'), $l6, 'Date values test 6' ) ;
is_deeply($bibentries->entry('L7')->get_field('warnings'), $l7, 'Date values test 7' ) ;
eq_or_diff($bibentries->entry('L8')->get_field('month'), '1', 'Date values test 8b - MONTH hacked to integer' ) ;
ok(is_undef($bibentries->entry('L9')->get_field('warnings')), 'Date values test 9' ) ;
ok(is_undef($bibentries->entry('L10')->get_field('warnings')), 'Date values test 10' ) ;
is_deeply($bibentries->entry('L11')->get_field('warnings'), $l11, 'Date values test 11' );
eq_or_diff($bibentries->entry('L11')->get_field('year'), '1996', 'Date values test 11a - DATE overrides YEAR' ) ;
is_deeply($bibentries->entry('L12')->get_field('warnings'), $l12, 'Date values test 12' );
eq_or_diff($bibentries->entry('L12')->get_field('month'), '1', 'Date values test 12a - DATE overrides MONTH' ) ;
# it means something if endyear is defined but null ("1935-")
ok(is_def_and_null($bibentries->entry('L13')->get_field('endyear')), 'Date values test 13 - range with no end' ) ;
ok(is_undef($bibentries->entry('L13')->get_field('endmonth')), 'Date values test 13a - ENDMONTH undef for open-ended range' ) ;
ok(is_undef($bibentries->entry('L13')->get_field('endday')), 'Date values test 13b - ENDDAY undef for open-ended range' ) ;
eq_or_diff( $out->get_output_entry('L13', $main), $l13c, 'Date values test 13c - labelyear open-ended range' ) ;
eq_or_diff( $out->get_output_entry('L14', $main), $l14, 'Date values test 14 - labelyear same as YEAR when ENDYEAR == YEAR') ;
eq_or_diff( $out->get_output_entry('L15', $main), $l15, 'Date values test 15 - labelyear should be undef, no DATE or YEAR') ;

# reset options and regenerate information
Biber::Config->setblxoption('labeldatespec', [ {content => 'date', type => 'field'},
                                               {content => 'eventdate', type => 'field'},
                                               {content => 'origdate', type => 'field'} ]);
$bibentries->del_entry('L17');
$bibentries->del_entry('L16');
$biber->prepare;
$out = $biber->get_output_obj;

eq_or_diff($bibentries->entry('L16')->get_labeldate_info->{field}{year}, 'eventyear', 'Date values test 16 - labelyear = EVENTYEAR when YEAR is (mistakenly) missing' ) ;
eq_or_diff($out->get_output_entry('L16', $main), $l16, 'Date values test 16a - labelyear = EVENTYEAR value when YEAR is (mistakenly) missing' );
eq_or_diff($bibentries->entry('L17')->get_labeldate_info->{field}{year}, 'year', 'Date values test 17 - labelyear = YEAR' ) ;
eq_or_diff($out->get_output_entry('L17', $main), $l17, 'Date values test 17a - labelyear = YEAR value when ENDYEAR is the same and ORIGYEAR is also present' ) ;

# reset options and regenerate information
Biber::Config->setblxoption('labeldatespec', [ {content => 'origdate', type => 'field'},
                                               {content => 'date', type => 'field'},
                                               {content => 'eventdate', type => 'field'} ]);
$bibentries->del_entry('L17');
$biber->prepare;
$out = $biber->get_output_obj;

eq_or_diff($bibentries->entry('L17')->get_labeldate_info->{field}{year}, 'origyear', 'Date values test 17b - labelyear = ORIGYEAR' ) ;
eq_or_diff($out->get_output_entry('L17', $main), $l17c, 'Date values test 17c - labelyear = ORIGYEAR value when ENDORIGYEAR is the same and YEAR is also present' ) ;

# reset options and regenerate information
Biber::Config->setblxoption('labeldatespec', [ {content => 'eventdate', type => 'field'},
                                               {content => 'date', type => 'field'},
                                               {content => 'origdate', type => 'field'} ], 'ENTRYTYPE', 'proceedings');
$bibentries->del_entry('L17');
$biber->prepare;
$out = $biber->get_output_obj;

eq_or_diff($bibentries->entry('L17')->get_labeldate_info->{field}{year}, 'eventyear', 'Date values test 17d - labelyear = EVENTYEAR' ) ;
eq_or_diff($bibentries->entry('L17')->get_labeldate_info->{field}{source}, 'event', 'Date values test 17d - source = event' ) ;
eq_or_diff($out->get_output_entry('L17', $main), $l17e, 'Date values test 17e - labelyear = ORIGYEAR-ORIGENDYEAR' ) ;

# reset options and regenerate information
Biber::Config->setblxoption('labeldatespec', [ {content => 'pubstate', type => 'field'} ], 'ENTRYTYPE', 'proceedings');

$bibentries->del_entry('L17');
$biber->prepare;
$out = $biber->get_output_obj;
eq_or_diff($bibentries->entry('L17')->get_labeldate_info->{field}{source}, 'pubstate', 'Source is non-date field');




my $era1 = q|    \entry{era1}{book}{}
      \field{sortinit}{3}
      \field{sortinithash}{7e21a31d9ef6ddc352701d4fa590bfbc}
      \field{labeldatesource}{}
      \field{month}{2}
      \field{origendyear}{219}
      \field{origyear}{221}
      \field{year}{379}
      \field{dateera}{bce}
      \field{origdateera}{bce}
      \field{origenddateera}{bce}
    \endentry
|;

my $era2 = q|    \entry{era2}{book}{}
      \field{sortinit}{1}
      \field{sortinithash}{53e85f4cf497d2a4e1d51786552bcbf1}
      \field{labeldatesource}{}
      \field{eventyear}{249}
      \field{origendyear}{44}
      \field{origyear}{49}
      \field{year}{197}
      \field{dateera}{bce}
      \field{eventdateera}{bce}
      \field{origdateera}{bce}
      \field{origenddateera}{bce}
    \endentry
|;

my $era3 = q|    \entry{era3}{book}{}
      \field{sortinit}{1}
      \field{sortinithash}{53e85f4cf497d2a4e1d51786552bcbf1}
      \field{labeldatesource}{}
      \field{eventday}{2}
      \field{eventmonth}{3}
      \field{eventyear}{250}
      \field{month}{2}
      \field{year}{196}
      \field{dateera}{bce}
      \true{eventdatejulian}
      \field{eventdateera}{ce}
    \endentry
|;

my $era4 = q|    \entry{era4}{book}{}
      \field{sortinit}{1}
      \field{sortinithash}{53e85f4cf497d2a4e1d51786552bcbf1}
      \field{labeldatesource}{}
      \field{eventyear}{1565}
      \field{origendyear}{1488}
      \field{origyear}{1487}
      \field{urlendyear}{1490}
      \field{urlyear}{1487}
      \field{year}{1034}
      \true{datecirca}
      \field{dateera}{ce}
      \true{eventdateuncertain}
      \field{eventdateera}{ce}
      \true{origenddatecirca}
      \field{origdateera}{ce}
      \field{origenddateera}{ce}
      \true{urldatecirca}
      \field{urldateera}{ce}
      \field{urlenddateera}{ce}
    \endentry
|;

my $time1 = q|    \entry{time1}{book}{}
      \field{sortinit}{2}
      \field{sortinithash}{8343b463aacf48517c044b4d2c9c45ed}
      \field{labeldatesource}{}
      \field{day}{3}
      \field{eventday}{3}
      \field{eventhour}{17}
      \field{eventminute}{7}
      \field{eventmonth}{1}
      \field{eventsecond}{34}
      \field{eventtimezone}{Z}
      \field{eventyear}{2001}
      \field{hour}{15}
      \field{minute}{0}
      \field{month}{1}
      \field{second}{0}
      \field{urlday}{3}
      \field{urlhour}{17}
      \field{urlminute}{7}
      \field{urlmonth}{1}
      \field{urlsecond}{34}
      \field{urltimezone}{+05\bibtzminsep 00}
      \field{urlyear}{2001}
      \field{year}{2001}
      \field{dateera}{ce}
      \field{eventdateera}{ce}
      \field{urldateera}{ce}
    \endentry
|;

my $range1 = q|    \entry{range1}{book}{}
      \field{sortinit}{1}
      \field{sortinithash}{53e85f4cf497d2a4e1d51786552bcbf1}
      \field{labeldatesource}{}
      \field{endyear}{}
      \field{eventendyear}{}
      \field{eventyear}{1565}
      \field{origendyear}{}
      \field{origyear}{2000}
      \field{year}{1034}
      \field{dateera}{ce}
      \field{eventdateera}{ce}
      \field{origdateera}{ce}
    \endentry
|;

my $season1 = q|    \entry{season1}{book}{}
      \field{sortinit}{2}
      \field{sortinithash}{8343b463aacf48517c044b4d2c9c45ed}
      \field{labeldatesource}{}
      \field{eventseason}{autumn}
      \field{eventyear}{2002}
      \field{season}{spring}
      \field{year}{2003}
      \field{dateera}{ce}
      \field{eventdateera}{ce}
    \endentry
|;

my $unspec1 = q|    \entry{unspec1}{book}{}
      \field{sortinit}{1}
      \field{sortinithash}{53e85f4cf497d2a4e1d51786552bcbf1}
      \field{labeldatesource}{}
      \field{endyear}{1999}
      \field{eventendyear}{1999}
      \field{eventyear}{1900}
      \field{origendmonth}{12}
      \field{origendyear}{1999}
      \field{origmonth}{1}
      \field{origyear}{1999}
      \field{urlday}{1}
      \field{urlendday}{31}
      \field{urlendmonth}{1}
      \field{urlendyear}{1999}
      \field{urlmonth}{1}
      \field{urlyear}{1999}
      \field{year}{1990}
      \field{dateunspecified}{yearindecade}
      \field{dateera}{ce}
      \field{enddateera}{ce}
      \field{eventdateunspecified}{yearincentury}
      \field{eventdateera}{ce}
      \field{eventenddateera}{ce}
      \field{origdateunspecified}{monthinyear}
      \field{origdateera}{ce}
      \field{origenddateera}{ce}
      \field{urldateunspecified}{dayinmonth}
      \field{urldateera}{ce}
      \field{urlenddateera}{ce}
    \\endentry
|;


my $unspec2 = q|    \entry{unspec2}{book}{}
      \field{sortinit}{1}
      \field{sortinithash}{53e85f4cf497d2a4e1d51786552bcbf1}
      \field{labeldatesource}{}
      \field{day}{1}
      \field{endday}{31}
      \field{endmonth}{12}
      \field{endyear}{1999}
      \field{month}{1}
      \field{year}{1999}
      \field{dateunspecified}{dayinyear}
      \field{dateera}{ce}
      \field{enddateera}{ce}
    \endentry
|;



Biber::Config->setblxoption('labeldatespec', [ {content => 'date', type => 'field'},
                                               {content => 'eventdate', type => 'field'},
                                               {content => 'origdate', type => 'field'},
                                               {content => 'urldate', type => 'field'}
                                             ]);

# Because datamodel valdidation saves warning fields
$bibentries->del_entry('era1');
$bibentries->del_entry('era2');
$bibentries->del_entry('era3');
$bibentries->del_entry('era4');
$bibentries->del_entry('range1');
$bibentries->del_entry('season1');
$bibentries->del_entry('time1');
$bibentries->del_entry('unspec1');
$bibentries->del_entry('unspec2');
Biber::Config->setoption('validate_datamodel', 0);
$biber->prepare;
$out = $biber->get_output_obj;

# Test negative dates and eras
eq_or_diff($out->get_output_entry('era1', $main), $era1, 'Date meta information - 1');
eq_or_diff($out->get_output_entry('era2', $main), $era2, 'Date meta information - 2');
eq_or_diff($out->get_output_entry('era3', $main), $era3, 'Date meta information - 3');
eq_or_diff($out->get_output_entry('era4', $main), $era4, 'Date meta information - 4');

# Test EDTF range markers
eq_or_diff($out->get_output_entry('range1', $main), $range1, 'Range - 1');

# Test EDTF seasons
eq_or_diff($out->get_output_entry('season1', $main), $season1, 'Seasons - 1');

# Test EDTF 5.2.2 Unspecified format
eq_or_diff($out->get_output_entry('unspec1', $main), $unspec1, 'Unspecified - 1');
eq_or_diff($out->get_output_entry('unspec2', $main), $unspec2, 'Unspecified - 2');

# Test EDTF times
eq_or_diff($out->get_output_entry('time1', $main), $time1, 'Times - 1');
