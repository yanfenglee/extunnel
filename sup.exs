### sup.exs
Code.require_file("http.exs")
Code.require_file("extunnel_sup.exs")

defmodule Sup do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, [])
	end

	def init([]) do
		children = [
			worker(HttpServ, [], function: :start_http, restart: :permanent),
            supervisor(ExtunnelSup, [[name: :extunnelsup]], restart: :permanent)
		]

		supervise(children, strategy: :one_for_one)
	end
end

Sup.start_link

receive do
end
