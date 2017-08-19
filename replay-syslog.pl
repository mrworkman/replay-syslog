#!/usr/bin/perl
#
# Copyright (c) 2009-2017 Stephen Workman

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

use strict;
use warnings;

use POSIX qw(strftime);
use IO::Socket::INET;
use Getopt::Long;

my $VERSION = "1.1.0";

# Command-line options
my %o;

# Set defaults
$o{Port} = 514;
$o{Delay} = 50;

my $protocol = "udp";

   #
   # Main Script
   CheckArgs();
   
   my $file   = $o{File};
   my $server = $o{Server};
   my $port   = $o{Port};
   
   # Load the source file
   open(FILE, "$file") || die "Couldn't read '$file'\n - $!";
   my @lines = <FILE>;
   close(FILE);
   
   # Connect to the server
   my $sock = IO::Socket::INET->new(
      PeerAddr => $server,
      PeerPort => $port,
      Proto    => $protocol,
   );
   
   die "Couldn't connect to server $server on $port using $protocol!\n" if(!$sock);
   
   # Replay all of the lines to the specified syslog server
   do {
      foreach my $line (@lines) {
         chomp $line;
         
         my $timestamp = strftime("%b %d %H:%M:%S", localtime(time));
         $timestamp =~ s/^([a-zA-Z]+\s)0/$1 /;
         
         # Replace the timestamp with the current date/time
         if (!$o{NoTs}) {
            $line =~ s/^\w+\s+\d+\s+\d+:\d+:\d+/$timestamp/;
         }

         # Remove chained IP if present
         $line =~ s|\d+\.\d+\.\d+\.\d+/||;
         
         SendSyslog($line);
         
         # Sleep for 50 milliseconds
         select(undef, undef, undef, $o{Delay} / 1000.0);

      }   
   } while (!$o{NoLoop});

sub CheckArgs {
   GetOptions(
      "delay=i"  => \$o{Delay},
      "file=s"   => \$o{File},
      "help"     => \$o{Help},
      "no-echo"  => \$o{NoEcho},
      "no-loop"  => \$o{NoLoop},
      "no-ts"    => \$o{NoTs},
      "port=i"   => \$o{Port},
      "server=s" => \$o{Server},
      "tcp"      => \$o{Tcp},
      "version"  => \$o{Version},
   ) || die "See --help\n\n";

   if ($o{Version}) {
      print("VERSION: $VERSION\n\n");
      exit 0;
   }

   if ($o{Help}) {
      PrintUsage();
      exit 0;
   }

   die "--file is required.\n" if (!$o{File});
   die "--server is required.\n" if (!$o{Server});

   $protocol = "tcp" if ($o{Tcp});
}

sub PrintUsage {
   my $scriptName = $0;

   $scriptName =~ s|.*/||;

   print("USAGE:\n\n");
   print(" $scriptName --file <file_name> --server <server_address> [--delay <N>] [--port <port>] [--tcp]\n");
   print("\n");

   print(" --delay <N> The number of milliseconds to wait between the replay of each\n");
   print("             message.\n");
   print(" --help      Print this help text and exit.\n");
   print(" --no-echo   Do not echo the messages to the screen.\n");
   print(" --no-loop   Do not replay the messages more than once.\n");
   print(" --no-ts     Do not change the timestamp before replaying the message.\n");
   print(" --port <port>\n");
   print("             The port to connect to on the syslog server.\n");
   print(" --server <server_address>\n");
   print("             The hostname or IP address of the server to send the messages to.\n");
   print(" --tcp       Use TCP instead of UDP.\n");
   print(" --version   Print this script's version and exit.\n");
   print("\n");

   exit 0;
}

sub SendSyslog {
   my $str = shift;
   
   print("$str\n") if (!$o{NoEcho});

   $sock->send("$str");
}