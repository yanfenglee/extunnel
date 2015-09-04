# extunnel
extunnel is a network tunneling software working as an encryption wrapper between clients and servers (remote/local), it is implemented in elixir,  maybe it's the smallest tunnel, but it's fast

## How to run
1. install elixir
2. run by

<pre> $ elixir extunnel.exs </pre>
 
## How to configure
open extunnel.exs, modify @client, @listen, @backend, @secret

example:

<pre>
  client side:
    @client true
    @listen 1234
    @backend {'127.0.0.1', 5555}
    @secret "extunnel"
    
  sever side:
    @client false
    @listen 5555
    @backend {'127.0.0.1', 6666}
    @secret "extunnel"
</pre>
