Code.load_file("http.exs")

defmodule Sup do
	use Supervisor

	def start_link(arg) do
		Supervisor.start_link(__MODULE__, arg)
	end

	def init(arg) do
		children = [
			worker(HttpServ, [arg], restart: :permanent)
		]

		supervise(children, strategy: :one_for_one)
	end
end

Sup.start_link 12345