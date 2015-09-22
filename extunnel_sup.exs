Code.require_file("extunnel.exs")

defmodule ExtunnelSup do
	use Supervisor

	def start_link do
		IO.puts "extunnelsup start"
		Supervisor.start_link(__MODULE__, [])
	end

	def init([]) do
        IO.puts "extunnel sup init"

		children = [
			worker(Extunnel, [], function: :start_link, restart: :transient)
		]

        supervise(children, strategy: :simple_one_for_one)
	end
end
