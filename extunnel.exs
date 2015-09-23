### extunnel
defmodule Extunnel do

    @client true
    @backend {'localhost', 5678}
    @secret "It is better to light a candle than curse the darkness."

    def start_link(port, name)do
        pid = spawn_link fn -> start(port) end
        IO.puts "start tunnel pid: #{inspect pid}"
        Process.register(pid, name)
        {:ok, pid}
    end

    def start(port) do
        {:ok, socket} = :gen_tcp.listen(port,[:binary, active: false, reuseaddr: true])
        IO.puts "Accepting connections on port #{port}"
        loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
        case :gen_tcp.accept(socket) do
            {:ok, frontend} ->
                state = :crypto.stream_init(:rc4, @secret)
                do_pump(frontend, state)
            {:error, reason} ->
                IO.puts "accept error: #{inspect reason}"
        end
        loop_acceptor(socket)
    end

    defp do_pump(frontend, state) do
        spawn fn ->
            Process.flag(:trap_exit, true)

            {ip,port} = @backend
            {:ok, backend} = :gen_tcp.connect(ip, port, [:binary, active: false])
            spawn_link fn -> pump(frontend, backend, state) end
            spawn_link fn -> pump(backend, frontend, state) end

            receive do
                {:EXIT,_,_} -> :gen_tcp.close(frontend)
            end
        end
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

#Extunnel.start
