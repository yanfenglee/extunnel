### http.exs
#Code.load_file("extunnel_sup.exs")

defmodule HttpServ do
	use Supervisor

    def start_link(arg, opts) do
      	Supervisor.start_link(__MODULE__, arg, opts)
    end

	def init(arg) do
		spawn_link fn -> listen(arg) end
		:ignore
	end

    def start_tunnel(port) do
        IO.puts "start port: #{port}"
        {:ok, child} = Supervisor.start_child(:ExtunnelSup, [port,[name: :"t#{port}"]])
        IO.puts "----- start port end"
    end

    def stop_tunnel(port) do
        Process.exit(:"t#{port}", :normal)
    end

	defp listen(port) do
		{:ok, socket} = :gen_tcp.listen(port,[:binary, packet: :line, active: false, reuseaddr: true])
        IO.puts "Accepting connections on port #{port}"
        loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
        case :gen_tcp.accept(socket) do
            {:ok, frontend} ->
            	spawn fn -> read(frontend) end
            {:error, reason} ->
                IO.puts "accept error: #{inspect reason}"
        end
        loop_acceptor(socket)
    end

    defp read(socket) do
        {:ok, data} = :gen_tcp.recv(socket, 0)
        #IO.puts data
        handleRaw(socket,data)

        read(socket)
    end

	defp handleRaw(socket, data) do
		sz = byte_size(data) - 15
		case data do
			<<"GET ", p::binary-size(sz), " HTTP/1.1\r\n">> ->
				handle(socket, p)
			_ ->
              #IO.puts "invalid #{data}"
		end

	end

	defp handle(socket, param) do
		case param do
			<<"/start/",p::binary>> ->
				{port,_} = Integer.parse(p)
				start(port)
                :ok = response(socket,"start port: #{port}")

			<<"/stop/",p::binary>> ->
				{port,_} = Integer.parse(p)
				stop(port)
                :ok = response(socket,"stop port: #{port}")

			_ -> IO.puts "error: #{param}"
		end
	end

    defp response(socket, data) do
        sz = byte_size(data)
        resp = "HTTP/1.1 200 OK\r\nContent-Length: #{sz}\r\n\r\n#{data}"
        :gen_tcp.send(socket,resp)
    end

	defp start(port) do
        start_tunnel(port)
	end

	defp stop(port) do
        stop_tunnel(port)
	end

end

#HttpServ.handleRaw "GET /start/123 HTTP/1.1"
