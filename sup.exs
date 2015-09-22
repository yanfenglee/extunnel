### sup.exs
Code.require_file("http.exs")
Code.require_file("extunnel_sup.exs")

defmodule Sup do
	use Supervisor

	def start_link(arg) do
		Supervisor.start_link(__MODULE__, arg)
	end

	def init(arg) do
		children = [
			worker(HttpServ, [arg], id: :httpserv, function: :start_http, restart: :permanent),
            supervisor(ExtunnelSup, [[name: :extunnelsup]], id: :extunnelsup, restart: :permanent)
		]

		supervise(children, strategy: :one_for_one)
	end
end

Sup.start_link 11112
receive do
	{:msg,contents} ->
end
