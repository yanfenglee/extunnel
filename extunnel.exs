
defmodule Extunnel do
    @client true
    @listen 1234
    @backend {'localhost', 2222}
    @secret "extunnel"

    def start do
      {:ok, socket} = :gen_tcp.listen(@listen,[:binary, active: false, reuseaddr: true])
      IO.puts "Accepting connections on port #{@listen}"
      loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
      {:ok, client} = :gen_tcp.accept(socket)
      state = :crypto.stream_init(:rc4, @secret)
      {ip,port} = @backend
      spawn fn ->
          IO.puts "begin connect backend..."
          {:ok, backend} = :gen_tcp.connect(ip, port, [:binary, active: false])
          IO.puts "begin spawn pump..."
          spawn fn -> pump(client, backend, state) end
          spawn fn -> pump(backend, client, state) end

          receive do
              {:msg,contents} ->
          end
      end

      loop_acceptor(socket)
    end

    defp pump(s1, s2, state) do
        newstate = s1 |> read |> enc(state) |> write(s2)
        pump(s1, s2, newstate)
    end

    defp enc(data, state) do
        if @client do
            :crypto.stream_encrypt(state, data)
        else
            :crypto.stream_decrypt(state, data)
        end
    end

    defp read(socket) do
        IO.puts "begin receive"
        {ret, data} = :gen_tcp.recv(socket, 0)
        IO.puts "receive: #{data}"
        data
    end

    defp write({state, data}, socket) do
        IO.puts "begin send"
        :ok = :gen_tcp.send(socket, data)
        IO.puts "send ok..."

        state
    end
end

Extunnel.start
