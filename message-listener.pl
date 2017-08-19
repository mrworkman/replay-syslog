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
$o{Address} = "127.0.0.1";
$o{Port} = 514;
$o{ReceiveBufferSize} = 2048;

my $protocol = "udp";

   #
   # Main Script
   CheckArgs();
     
   my $listenAddress = $o{Address};
   my $port = $o{Port};
     
   print "Listening on: $protocol $port\n";
     
   my $sock; 
   
   # Open an appropriate port
   if ($protocol eq "udp") {
      $sock = IO::Socket::INET->new(
         LocalhHost => $listenAddress,
         LocalPort  => $port,
         Proto      => $protocol,
      );
   } else {
      $sock = IO::Socket::INET->new(
         LocalhHost => $listenAddress,
         LocalPort  => $port,
         Proto      => $protocol,
         Listen     => 5,
         Reuse      => 1
      );
   }

   die "Couldn't open socket!\n" if(!$sock);
   
   print("Use CTRL+C to abort.\n");

   # Print incoming messages to the screen
   while(1) {
      my $msg;

      # TCP
      if ($protocol eq "tcp") {
         my $csock = $sock->accept();
         
         do {
            $csock->recv($msg, $o{ReceiveBufferSize});
            print("$msg\n");
         } while ($msg ne "");

         next;         
      }

      # UDP
      $sock->recv($msg, $o{ReceiveBufferSize});
      print("$msg\n");
   }

sub CheckArgs {
   GetOptions(
      "address=s"        => \$o{Server},
      "help"             => \$o{Help},
      "port=i"           => \$o{Port},
      "receive-buffer=i" => \$o{ReceiveBufferSize},
      "tcp"              => \$o{Tcp},
      "version"          => \$o{Version},
   ) || die "See --help\n\n";

   if ($o{Version}) {
      print("VERSION: $VERSION\n\n");
      exit 0;
   }

   if ($o{Help}) {
      PrintUsage();
      exit 0;
   }

   $protocol = "tcp" if ($o{Tcp});
}

sub PrintUsage {
   my $scriptName = $0;

   $scriptName =~ s|.*/||;

   print("USAGE:\n\n");
   print(" $scriptName [--address <listen_address>] [--port <port>] [--tcp] [--receive-buffer <N>]\n");
   print("\n");

   print(" --address <listen_address>\n");
   print("             The hostname or IP address to listen on. (Default: 127.0.0.1).\n");
   print(" --help      Print this help text and exit.\n");
   print(" --port <port>\n");
   print("             The port to listen for incoming messages on.\n");
   print(" --receive-buffer <N>\n");
   print("             The size of the receive buffer. (Default: 2048).\n");
   print(" --tcp       Use TCP instead of UDP.\n");
   print(" --version   Print this script's version and exit.\n");
   print("\n");

   exit 0;
}