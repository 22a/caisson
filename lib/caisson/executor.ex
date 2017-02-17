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

    {:ok, proc} = gen_proc lang
    {:ok, proc_path} = Briefly.create
    File.write!(proc_path, proc)

    {:ok, payload_path} = Briefly.create
    File.write!(payload_path, payload)

    {output, exit_status} =
      System.cmd "bash", ["bin/execute.sh",
                          lang,
                          timelimit,
                          memlimit,
                          payload_path,
                          proc_path], stderr_to_stdout: true

    send_resp(conn, 200, "#{output}")
  end

  defp gen_proc(lang) do
    case Map.has_key?(@lang_proc, lang) do
      true ->
        {:ok, Enum.join(@lang_proc[lang], " && ")}
      false ->
        {:error, :unsupported_lang}
    end
  end
end
