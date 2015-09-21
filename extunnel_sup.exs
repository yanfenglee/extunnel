Code.require_file("extunnel.exs")

defmodule ExtunnelSup do
	use Supervisor

	def start_link(arg, opts) do
		IO.puts "extunnelsup start"
		Supervisor.start_link(__MODULE__, arg, opts)
	end

	def init(arg) do
        IO.puts "extunnel sup init"

		children = [
			worker(Extunnel, [arg,[]], restart: :transient)
		]

        supervise(children, strategy: :simple_one_for_one)
	end
end
