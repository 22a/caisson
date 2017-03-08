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

    # TODO: handle case where lang is unsupported
    {:ok, {proc, image}} = get_metadata lang

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
                          proc_path,
                          image], stderr_to_stdout: true

    send_resp(conn, 200, "#{exit_status}\n#{output}")
  end

  defp get_metadata(lang) do
    if Map.has_key?(@lang_proc, lang) do
      image = @lang_proc[lang][:image]
      compile_cmd = @lang_proc[lang][:compile_cmd]
      execute_cmd = @lang_proc[lang][:execute_cmd]
      proc =
        case compile_cmd do
          "" ->
            execute_cmd
          _ ->
            "#{compile_cmd} && #{execute_cmd}"
        end
      {:ok, {proc, image}}
    else
      {:error, :unsupported_lang}
    end
  end
end
