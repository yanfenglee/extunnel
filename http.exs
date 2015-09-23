### http.exs
Code.load_file("extunnel_sup.exs")

defmodule HttpServ do

	def start_http do
		pid = spawn_link fn -> listen(31415) end
		{:ok, pid}
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
		        case ExtunnelSup.start_extunnel(port) do
		        	{:ok, _} ->
						response(socket,"OK")
					{:error,reason} ->
						IO.puts reason
		                response(socket,"FAIL")
		        end

			<<"/stop/",p::binary>> ->
				{port,_} = Integer.parse(p)
		        ExtunnelSup.stop_extunnel(port)
                response(socket,"OK")

			<<"/info">> ->
				response(socket, "#{inspect Process.registered()}")

			_ -> response(socket,"ERROR")
		end
	end

    defp response(socket, data) do
        sz = byte_size(data)
        resp = "HTTP/1.1 200 OK\r\nContent-Length: #{sz}\r\n\r\n#{data}"
        :gen_tcp.send(socket,resp)
    end

end
