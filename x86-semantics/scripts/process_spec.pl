#!/usr/bin/perl

# Common includes
use strict;
use warnings;
use Getopt::Long;
use File::Compare;
use File::Basename;
use File::chdir;
use Cwd;
use File::Path qw(make_path remove_tree);
use lib qw( /home/sdasgup3/scripts-n-docs/scripts/perl/ );
use utils;
use lib qw( /home/sdasgup3/Github/binary-decompilation/x86-semantics/scripts/ );
use kutils;
use File::Find;
use File::chdir;
use Cwd;

=pod
This file is used to create the *spec.k files used for krpove.

perl create_spec.pl --file  <file> --strata_path <path to circuits>
  where file contains list of opcodes.
=cut

# Using GetOPtions
my $file        = "";
my $strata_path = "/home/sdasgup3/Github/strata-data/circuits";
my $instantiated_instr_path =
  "/home/sdasgup3/Github/strata-data/data-regs/instructions/";
my $specdir = "/home/sdasgup3/Github/binary-decompilation/x86-semantics/specs/";
my $derivedInstructions =
"/home/sdasgup3/Github/binary-decompilation/x86-semantics/derivedInstructions/";
my $help           = "";
my $stratum        = "";
my $readmod        = "";
my $createspec     = "";
my $postprocess    = "";
my $kprove         = "";
my $getoplist      = "";
my $all            = "";
my $genincludes    = "";
my $checksanity    = "";
my $gitdiff        = "";
my $gitadd         = "";
my $speconly       = "";
my $singlefiledefn = "";
my $path           = "";
my $nightlyrun           = "";
my $getimm           = "";

GetOptions(
    "help"           => \$help,
    "file:s"         => \$file,
    "stratum"        => \$stratum,
    "readmod"        => \$readmod,
    "createspec"     => \$createspec,
    "getoplist"      => \$getoplist,
    "kprove"         => \$kprove,
    "postprocess"    => \$postprocess,
    "all"            => \$all,
    "genincludes"    => \$genincludes,
    "checksanity"    => \$checksanity,
    "gitdiff"        => \$gitdiff,
    "speconly"       => \$speconly,
    "gitaddspec"     => \$gitadd,
    "singlefiledefn" => \$singlefiledefn,
    "getimm" => \$getimm,
    "nightlyrun" => \$nightlyrun,
    "path:s"         => \$path,
    "strata_path:s"  => \$strata_path,
) or die("Error in command line arguments\n");

##
my $sfp;
my $removeComment;

if ( "" ne $singlefiledefn ) {

    my $singleFile = "x86-instructions-semantics.k";
    open( $sfp, ">", $singleFile ) or die "Can't open: $!";
    $removeComment = 0;

    print $sfp "requires \"x86-configuration.k\"" . "\n";
    print $sfp "requires \"x86-flag-checks-syntax.k\"" . "\n\n";
    print $sfp "module X86-INSTRUCTIONS-SEMANTICS" . "\n";
    print $sfp "  imports X86-CONFIGURATION" . "\n";
    print $sfp "  imports X86-FLAG-CHECKS-SYNTAX" . "\n";

    find( \&mergeToSingleFile, "instructions/" );

    #print $sfp "endmodule";
    #    close($sfp);

    #    $singleFile = "test2.k";
    #    open( $sfp, ">", $singleFile ) or die "Can't open: $!";
    $removeComment = 1;

    #    print $sfp "requires \"x86-configuration.k\"" . "\n\n";
    #    print $sfp "module X86-DERIVED-INSTRUCTIONS-SEMANTICS" . "\n";
    #    print $sfp "  imports X86-CONFIGURATION" . "\n";

    find( \&mergeToSingleFile, "derivedInstructions/" );

    print $sfp "endmodule";
    close($sfp);

    exit(0);
}

sub mergeToSingleFile {
    my $file = $_;
    if ( !( -f $file ) or ( $file !~ m/\.k$/ ) ) {
        return;
    }

    my $koutput = "$file";

    #print "Merging $koutput\n";

    open( my $fp, "<", $koutput ) or die "Can't open ::$koutput\:: $!";
    my @lines = <$fp>;

    for my $line (@lines) {
        if ( $line =~ m/^module (.*)/ ) {
            print $sfp "// " . lc($1) . "\n";
            next;
        }
        if ( $line =~ m/imports/ ) {
            next;
        }
        if ( $line =~ m/^requires "(.*\.k)"/ ) {
            next;
        }
        if ( $line =~ m/Autogenerated/ ) {
            next;
        }
        if ( $line =~ m/endmodule/ ) {
            print $sfp "\n";
            if ( $removeComment == 1 ) {
                last;
            }
            else {
                next;
            }
        }
        print $sfp $line;
    }
}

if("" ne $nightlyrun) {
  my @fnames = (
  "stratum_8",
  "stratum_9",
  "stratum_10",
  "stratum_11",
  "stratum_12",
  "stratum_13",
  "stratum_14",
  "stratum_15",
      );
  my @counts = ( 47, 21, 16, 14, 8, 6, 3, 2,);

  for (my $i = 0 ; $i < scalar(@fnames); $i++ ) {  
    my $file = "/home/sdasgup3/Github/binary-decompilation/x86-semantics/docs/relatedwork/strata/$fnames[$i].txt";
    my $numOfOpcodes = $counts[$i];

    execute("./scripts/process_spec.pl --file $file -all 1> $file.all.log 2>&1 ", 2);
    execute("./scripts/process_spec.pl --singlefiledefn ", 2);
    execute("./scripts/run.pl --compile ", 2);
  }
  
  exit(0);
}

open( my $fp, "<", $file ) or die "cannot open: $!";
my @lines      = <$fp>;
my $debugprint = 0;

## Git diff
if ( "" ne $gitdiff ) {
    for my $opcode (@lines) {
        chomp $opcode;
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }

        my $koutput = "$derivedInstructions/x86-${opcode}.k";
        execute("git diff -U0 $koutput");
    }
}

## Git add
if ( "" ne $gitadd ) {
    for my $opcode (@lines) {
        chomp $opcode;
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }

        my $filesToAdd = "";
        my $specfile   = "$specdir/x86-semantics_${opcode}_spec.k";
        my $specout    = "$specdir/x86-semantics_${opcode}_spec.output";
        my $koutput    = "$derivedInstructions/x86-${opcode}.k";

        if ( $speconly eq "" ) {
            $filesToAdd = "$specfile $specout $koutput";
        }
        else {
            $filesToAdd = $specfile;
        }
        execute("git add $filesToAdd");
    }
}

## Create a spec file
if ( "" ne $createspec ) {
    for my $opcode (@lines) {
        chomp $opcode;
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }
        kutils::createSpecFile( $opcode, $strata_path, $specdir,
            $instantiated_instr_path, $debugprint );
        print "\n";
    }
}

## Run krpove on spec file
if ( "" ne $kprove ) {
    for my $opcode (@lines) {
        chomp $opcode;
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }
        kutils::runkprove( $opcode, $specdir, $debugprint );
        print "\n";
    }
}

## Post process
if ( "" ne $postprocess ) {
    for my $opcode (@lines) {
        chomp $opcode;
        
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }
        
        my $isManuallyGenerated = kutils::checkManuallyGenerated( $opcode, $debugprint);
        if ( 1 == $isManuallyGenerated ) {
            utils::warnInfo("$opcode: Manually Generated");
            next;
        }

        kutils::postProcess( $opcode, $specdir, $derivedInstructions,
            $debugprint );
        print "\n";
    }
}

if ( "" ne $all ) {
    for my $opcode (@lines) {
        chomp $opcode;
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }
        kutils::createSpecFile( $opcode, $strata_path, $specdir,
            $instantiated_instr_path, $debugprint );
        kutils::runkprove( $opcode, $specdir, $debugprint );
        kutils::postProcess( $opcode, $specdir, $derivedInstructions,
            $debugprint );
        print "\n";
    }
}

if ( "" ne $genincludes ) {
    my @reqs    = ();
    my @imports = ();
    my @syntaxs = ();

    for my $opcode (@lines) {
        chomp $opcode;
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }
        my $req         = "requires \"x86-${opcode}.k\"";
        my $koutput     = "$derivedInstructions/x86-${opcode}.k";
        my $matches_ref = utils::myGrep( "-SEMANTICS", "sdasgup3", $koutput );
        my @matches     = @{$matches_ref};

        if ( scalar(@matches) > 1 ) {
            utils::failInfo("$opcode: More that one top level module");
        }

        my $semantic_module = $matches[0];
        $semantic_module =~ s/module //g;
        $semantic_module = utils::trim($semantic_module);
        my $import = "  imports $semantic_module";

        my $syntax = $opcode =~ s/_.*//gr;
        $syntax = "                              |  \"$syntax\" [token]";

        push @reqs,    $req;
        push @imports, $import;
        push @syntaxs, $syntax;

    }

    print join( "\n", @reqs );

    print "\n";

    print join( "\n", @imports );

    print "\n";

    print join( "\n", @syntaxs );
}

if ( "" ne $checksanity ) {
    my @reqs    = ();
    my @imports = ();
    my @syntaxs = ();

    my @patterns = (
        "bitwidthMInt",             "plugInMask",
        "extractMask",              "zeroExtend",
        "signExtend",               "splitVectorHelper",
        "minFloat",                 "maxFloat",
        "Float2MInt\\\(MInt2Float", "MInt2Float\\\(Float2MInt",
        "_\\\\s+",                  "regstate",
    );

    my $antipattern = "convTo\|CF\|ZF\|SF\|PF\|OF\|AF";

    for my $opcode (@lines) {
        chomp $opcode;
        my $isSupported =
          kutils::checkSupported( $opcode, $strata_path, $derivedInstructions,
            $debugprint );
        if ( 0 == $isSupported ) {
            utils::warnInfo("$opcode: Unsupported");
            next;
        }
        my $koutput = "$derivedInstructions/x86-${opcode}.k";

        utils::info("$opcode: Check Sanity");
        for my $pattern (@patterns) {
            my $matches_ref = utils::myGrep( $pattern, "sdasgup3", $koutput );
            my @matches = @{$matches_ref};

            if ( ( $pattern eq "regstate" ) ) {
                if ( ( scalar(@matches) == 0 ) ) {
                    utils::failInfo("$pattern: $koutput");
                }
            }
            elsif ( scalar(@matches) > 0 ) {
                utils::failInfo("$pattern: $koutput");
            }
        }

        my $matches_ref = utils::myGrep( "\\|->", $antipattern, $koutput );
        my @matches = @{$matches_ref};
        if ( scalar(@matches) > 0 ) {
            utils::failInfo( "Scratch Pad:" . $koutput );
        }

        print "\n";
    }
}

## Get the stratum and num of instr of a particular circuit
if ( "" ne $stratum ) {
    if ( "" eq $strata_path ) {
        info(" Need-- strata_path ");
        exit(0);
    }

    #info(" Using strata_path = $strata_path ");
    for my $opcode (@lines) {
        chomp $opcode;
        my ( $depth, $count ) =
          kutils::find_stratum( $opcode, $strata_path, $debugprint );
        print " \n $opcode" . " \t " . $depth . " \t " . $count . " \n ";
    }
    exit(0);
}

## Get the read/write reg set
if ( "" ne $readmod ) {

    #info(" Using strata_path = $strata_path ");
    for my $opcode (@lines) {
        chomp $opcode;
        my ( $instr, $metadata, $rwset ) =
          kutils::getReadMod( $opcode, $instantiated_instr_path, $debugprint );
        print " \n $opcode" . " \n "
          . $instr . " \n "
          . $metadata . " \n "
          . $rwset . " \n ";
    }
    exit(0);
}

## Get all the registers involved in a circuit
if ( "" ne $getoplist ) {

    #info(" Using strata_path = $strata_path ");
    for my $opcode (@lines) {
        chomp $opcode;
        my $opList = kutils::getOpList( $opcode, $strata_path, $debugprint );
        print $opList;
    }
    exit(0);
}
