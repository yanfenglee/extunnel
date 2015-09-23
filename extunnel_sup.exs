Code.require_file("extunnel.exs")

defmodule ExtunnelSup do
	use Supervisor

	def start_link(opts) do
		Supervisor.start_link(__MODULE__, [], opts)
	end

	def init([]) do
		children = [
			worker(Extunnel, [], function: :start_link, restart: :transient)
		]
        supervise(children, strategy: :simple_one_for_one)
	end

	def start_extunnel(port) do
		case getpid(port) do
			nil ->
				sup = Process.whereis(:extunnelsup)
				{:ok, _} = Supervisor.start_child(sup, [port, toatom(port)])
			pid ->
				IO.puts "port already started: #{port}, #{inspect pid}"
		end
	end

	defp toatom(port) do
		:"t#{port}"
	end

	defp getpid(port) do
		Process.whereis(toatom(port))
	end

	def stop_extunnel(port) do
		case getpid(port) do
			nil -> IO.puts "port not open: #{port}"
			pid -> Process.exit(pid, :shutdown)
		end
	end
end
