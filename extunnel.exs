
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
        {:ok, frontend} = :gen_tcp.accept(socket)
        state = :crypto.stream_init(:rc4, @secret)
        {ip,port} = @backend

        spawn fn ->
            Process.flag(:trap_exit, true)

            {:ok, backend} = :gen_tcp.connect(ip, port, [:binary, active: false])
            spawn_link fn -> pump(frontend, backend, state) end
            spawn_link fn -> pump(backend, frontend, state) end

            receive do
                {:EXIT,from,reason} -> :gen_tcp.close(frontend)
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
        {:ok, data} = :gen_tcp.recv(socket, 0)
        data
    end

    defp write({state, data}, socket) do
        :ok = :gen_tcp.send(socket, data)
        state
    end
end

Extunnel.start
