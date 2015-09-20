Code.load_file("extunnel.exs")

defmodule HttpServ do
	use Supervisor

	def start_link(arg) do
		Supervisor.start_link(__MODULE__, arg)
	end

	def init(arg) do
		listen(arg)
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
        IO.puts data
        handleRaw(socket,data)

        read(socket)
    end

	defp handleRaw(socket, data) do
		sz = byte_size(data) - 15
		case data do
			<<"GET ", p::binary-size(sz), " HTTP/1.1\r\n">> ->
				handle(socket, p)
			_ ->
				IO.puts "invalid #{data}"
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
		IO.puts "start port: #{port*2}"
	end

	defp stop(port) do
		IO.puts "stop port: #{port*20}"
	end

end

#HttpServ.handleRaw "GET /start/123 HTTP/1.1"
