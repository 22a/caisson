defmodule Caisson.Executor do
  import Plug.Conn

  @lang_proc Application.get_env(:caisson, :lang_proc)

  def init(options) do
    options
  end

  def call(conn, _opts) do
    %{"payload" => payload,
      "lang" => lang,
      "timelimit" => timelimit,
      "memlimit" => memlimit} = conn.params

    # match on the provided lang choose procedure
    # IO.inspect @lang_proc

    {output, exit_status} = System.cmd "bash", ["bin/execute.sh", lang, timelimit, memlimit, payload], stderr_to_stdout: true

    send_resp(conn, 200, "#{output} exited with status #{exit_status}")
  end
end
