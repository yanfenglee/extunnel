
defmodule Extunnel do
    @listen 31415
    @backend {'localhost', 27182}
    @secret "It is better to light a candle than curse the darkness."

    def start do
        {:ok, socket} = :gen_tcp.listen(@listen,[:binary, active: false, reuseaddr: true])
        IO.puts "Accepting connections on port #{@listen}"
        loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
        case :gen_tcp.accept(socket) do
            {:ok, frontend} ->
                state = :crypto.stream_init(:rc4, @secret)
                on_accept(frontend, state)
            {:error, reason} ->
                IO.puts "accept error: #{inspect reason}"
        end
        loop_acceptor(socket)
    end

    defp on_accept(frontend, state) do
        spawn fn ->
            {ip,port} = @backend
            case :gen_tcp.connect(ip, port, [:binary, active: false]) do
                {:ok, backend} -> pump_all(frontend, backend, state)
                _ -> nil
            end
            :gen_tcp.close(frontend)
        end
    end

    defp pump_all(frontend, backend, state) do
        Process.flag(:trap_exit, true)
        spawn_link fn -> pump(frontend, backend, state) end
        spawn_link fn -> pump(backend, frontend, state) end

        receive do
            {:EXIT,_,_} -> :gen_tcp.close(backend)
        end
    end 

    defp pump(s1, s2, state) do
        newstate = s1 |> read |> enc(state) |> write(s2)
        pump(s1, s2, newstate)
    end

    defp enc(data, state) do
        :crypto.stream_encrypt(state, data)
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
