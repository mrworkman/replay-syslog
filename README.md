# replay-syslog
A simple script for replaying syslog messages from a file.

I wrote this script years ago for the purposes of testing syslog and ArcSight flex-connector parsers.
All it does is it reads a file, changes the timestamp, removes one chained IP address (if present), and
replays it repeatedly to the specified syslog destination. Since others have found this script useful
over the last several years (to my surprise), I thought I'd make it generally available.

Also included: `message-listener.pl`. This is just a light-weight script I wrote for watching the CEF
output from ArcSight connectors.

## Help

### `replay-syslog.pl`

    USAGE:
    
     replay-syslog.pl --file <file_name> --server <server_address> [--delay <N>] [--port <port>] [--tcp]
    
     --delay <N> The number of milliseconds to wait between the replay of each
                 message.
     --help      Print this help text and exit.
     --no-echo   Do not echo the messages to the screen.
     --no-loop   Do not replay the messages more than once.
     --no-ts     Do not change the timestamp before replaying the message.
     --port <port>
                 The port to connect to on the syslog server.
     --server <server_address>
                 The hostname or IP address of the server to send the messages to.
     --tcp       Use TCP instead of UDP.
     --version   Print this script's version and exit.
    
 ### `message-listener.pl`
 
     USAGE:
    
     message-listener.pl [--address <listen_address>] [--port <port>] [--tcp] [--receive-buffer <N>]
    
     --address <listen_address>
                 The hostname or IP address to listen on. (Default: 127.0.0.1).
     --help      Print this help text and exit.
     --port <port>
                 The port to listen for incoming messages on.
     --receive-buffer <N>
                 The size of the receive buffer. (Default: 2048).
     --tcp       Use TCP instead of UDP.
     --version   Print this script's version and exit.
    
