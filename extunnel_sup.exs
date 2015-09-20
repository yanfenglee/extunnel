Code.load_file("extunnel.exs")

defmodule Extunnel.Sup do
	use Supervisor

	def start_link(arg, opts) do
		Supervisor.start_link(__MODULE__, arg, opts)
	end

	def init(arg) do
		children = [
			worker(Extunnel, [arg,[]], restart: :transient)
		]

        #supervise(children, strategy: :simple_one_for_one)
	end
end

