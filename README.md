# extunnel
simple encrypt tunnel implemented in elixir, maybe it's the smallest tunnel
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
