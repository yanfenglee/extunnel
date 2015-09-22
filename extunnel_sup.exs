Code.require_file("extunnel.exs")

defmodule ExtunnelSup do
	use Supervisor

	def start_link(opts) do
		IO.puts "extunnelsup start"
		Supervisor.start_link(__MODULE__, [], opts)
	end

	def init([]) do
        IO.puts "extunnel sup init"

		children = [
			worker(Extunnel, [], function: :start_link, restart: :transient)
		]

        supervise(children, strategy: :simple_one_for_one)
	end

	def start_extunnel(port) do
		pid = Process.whereis(:extunnelsup)
		#IO.puts "whereis sup: #{is_pid(pid)}"
		#IO.puts "#{Process.registered}"
	 	Supervisor.start_child(pid, [])
	end
end
