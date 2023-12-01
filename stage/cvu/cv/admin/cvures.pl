#!/usr/local/bin/perl
# 
# $Header: opsm/cvutl/cvures.pl /main/1 2014/10/23 17:51:21 spavan Exp $
#
# cvures.pl
# 
# Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      cvures.pl - script to create pid file for use by resource
#
#    DESCRIPTION
#      Create pid file for the cluvfy command line launched by cvu resource
#
#    NOTES
#      When the CVU resource agent spawns cluvfy command the shell script
#      'cluvfy' will spawn a java process in the background. Following the 
#      launching of the java process the script will invoke this perl script. 
#      This script will find the pid of the spawned java process running and 
#      write the pid in file '$GI_BASE/crsdata/$HOST/cvu/init/cvu.pid'. If no 
#      java process is found then this script will exit without any errors. In
#      the normal course of execution java process will clean the pid file and
#      exit. The agent tries to looks at pid file in two different situations. 
#      First is when stop is invoked (user/crs initiated) for the ora.cvu 
#      resource. It reads the pid file and tries to kill the running java
#      command. Second is when the next check time has arrived. If the pid file
#      is still around then the java process is assumed to be hung and an
#      attempt to clean it up is made. 
#      In this script if the pid file exists, presumably from a previous run,
#      and a java process with the specified pid is running then the java
#      process will be killed. If the java process is not running then
#      the pid file will be deleted and a new pid file for this run will be 
#      created.
#
#    MODIFIED   (MM/DD/YY)
#    spavan      09/08/14 - perl script used by cvu resource
#    spavan      09/08/14 - Creation
# 

use English;
use strict;
use Sys::Hostname;
use File::Spec::Functions;

# Perl status codes
use constant {
  SUCC_CODE => 0 ,
  FAIL_CODE => 1 ,
  ERROR_PID => -1 ,
  NULL_PID  => -2
};

sub debug_out
#---------------------------------------------------------------------
# Function: Print debugging list
#
# Args    : Debugging list to print
#
# Returns : None
#---------------------------------------------------------------------
{
   print STDOUT "[cvures debug]";
   foreach (@_) {
     print STDOUT " ", $_;
   }
   print STDOUT "\n";
}

sub read_pid_from_cvu_pid_file
#---------------------------------------------------------------------
# Function: Read the cluvfy resource PID for previous execution from the CVU PID
#           file. Reads only the first line if multiple line exists.
#
# Args    : Pid file
#
# Returns : NULL_PID (if PID file is not found) 
#           PID value found in file (if PID file is found)
#---------------------------------------------------------------------
{
  my ($pid_file) = @_;
  my $cvu_pid = NULL_PID;

  if (-e $pid_file && -r $pid_file) {
    open(PF, $pid_file);
    while (<PF>) {
      chomp;
      $cvu_pid = $_;
      debug_out ("found $cvu_pid in pid file");
      last;
    }
    close(PF);
  }
  return $cvu_pid;
}

sub kill_cluvfy_pid
#---------------------------------------------------------------------
# Function: kill the cluvfy resource command line PID if we find a match.
#
# Args    : pid to match and kill
#           log location
#           pid location
#
# Returns : None
#---------------------------------------------------------------------
{
   my ($read_pid, $log_location, $pid_location) = @_;
   my @cvu_pid_list = get_cluvfy_pid_list($log_location, $pid_location);
   foreach (@cvu_pid_list) {
      if ($_ == $read_pid) {
         debug_out ("found old cluvfy with $read_pid running and killing it");
         send_kill_signal ($read_pid);
         return ;
      }
   }
   debug_out ("didn't find $read_pid running");
   return;
}

sub get_cluvfy_pid_list
#---------------------------------------------------------------------
# Function: Get a list of cluvfy resource commandline PID(s).
#           Match against cluvfy command line, resource system property.
#
# Args    : log location
#           pid location
#
# Returns : List of PID(s) (if any)
#---------------------------------------------------------------------
{
   my ($log_location, $pid_location) = @_;
   debug_out("Getting CVU resource commandline PIDs");

   # Compile the match regex on first entry
   my $pid_location_qm = quotemeta($pid_location);
   my $resource_qm = quotemeta("-DRUNNING.MODE=cvuresource");
   my $cmdline_qm = quotemeta(
       "oracle.ops.verification.client.CluvfyDriver comp healthcheck -mandatory -_format");
   my $log_location_qm = quotemeta ($log_location);
   my $match_regex = qr/$cmdline_qm.*$resource_qm.*$log_location_qm.*$pid_location_qm/p;

   # Return matching PID(s) to caller
   my @cvu_pid_list =
       get_matching_pid_list($match_regex);
   debug_out("Done Getting CVU resource PIDs");
   return @cvu_pid_list;
}

sub get_matching_pid_list
#---------------------------------------------------------------------
# Function: Get a PID list matching a regex
#
# Args    : Compiled match regex
#
# Returns : List of matching PIDs (if any)
#---------------------------------------------------------------------
{
  my ($match_regex) = @_;

  my @pid_list;
  my %pid_hash = get_pid_hash();

  foreach my $pid (sort keys(%pid_hash)) {
    my $command = $pid_hash{$pid};
    if ($command =~ $match_regex) {
      debug_out("Match for PID $pid");
      push @pid_list, $pid;
    }
  }
  return @pid_list;
}

sub get_pid_hash
#---------------------------------------------------------------------
# Function: Return a hash of Java PIDs to command lines
#
# Args    : None
#
# Returns : PID hash (key PID, value corresponding command line)
#---------------------------------------------------------------------
{
  my %pid_hash;
  my $platform = $OSNAME;

  my $jps = catfile($ENV{"ORACLE_HOME"}, "jdk", "bin", "jps");
  my @pid_lines = `$jps -lmv`;
  foreach my $pid_line (@pid_lines) {
     if ($pid_line =~ /^(\d+)\s*(.*)$/) {
        $pid_hash{$1} = $2;
     }
  }

  return %pid_hash;
}

sub send_kill_signal
#---------------------------------------------------------------------
# Function: Send kill signal
#
# Args    :  Process number
#
# Returns : SUCC_CODE (operation initiated);
#---------------------------------------------------------------------
{
  my ($cvu_pid) = @_;

  kill ABRT => $cvu_pid;
  return SUCC_CODE;
}

my $start_deployment_interval = 3;
my $pid_arg = "-DCV_PID_FILE=";
my $pid_file_path;

#Extract cvu pid file location from command line args
my $pid_arg_idx = index($ARGV[2], $pid_arg);
$pid_file_path = substr($ARGV[2], $pid_arg_idx + length($pid_arg));

if (!$pid_file_path) {
   die "path for cluvfy pid file couldn't be initialized";
}

#check if old pid file exists
my $read_pid = read_pid_from_cvu_pid_file($pid_file_path);
if ($read_pid != NULL_PID) {
   # pid file exists. Check if cluvfy java process with pid exists and kill it.
   kill_cluvfy_pid ($read_pid, $ARGV[1], $ARGV[2]);

   #remove old pid file
   debug_out ("removing pid file $pid_file_path");
   unlink ($pid_file_path);
} else {
   debug_out ("ok. pid file ", $pid_file_path, " not found");
}

#create pid file for current run
my $maxRetry = 5; 
my $iter=0;
my $cvu_pid;
my $platform = $OSNAME;

my @cvu_pid_list;
while ($iter < $maxRetry) {
    sleep($start_deployment_interval);
    @cvu_pid_list = get_cluvfy_pid_list($ARGV[1], $ARGV[2]);
    if (@cvu_pid_list) {
       last;
    }
    $iter++;
}

$cvu_pid = $cvu_pid_list[0];

if (!$cvu_pid) {
   die "cluvfy java was not running and pid not found\n";
}

open(PF, ">$pid_file_path");
print PF "$cvu_pid\n";
close(PF);

#read pid to ensure that it got created
$read_pid = read_pid_from_cvu_pid_file($pid_file_path);
if ($read_pid == NULL_PID)
{
   debug_out(" ERROR:FATAL Error: Could not create $pid_file_path\n");
}
