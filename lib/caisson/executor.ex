defmodule Caisson.Executor do
  import Plug.Conn

  @lang_proc Application.get_env(:caisson, :lang_proc)

  def init(options) do
    options
  end

  def call(conn, _opts) do
    {:ok, body, _thing} = read_body conn
    {:ok, %{"payload" => payload,
      "lang" => lang,
      "timelimit" => timelimit,
      "memlimit" => memlimit}} = Poison.decode(body)

    case get_metadata lang do
      {:ok, {proc, image}} ->
        # TODO: real error handling for these tempfile creations
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

        resp_json = Poison.encode!(%{exit_status: exit_status, output: output})
        send_resp(conn, 200, resp_json)

      {:error, :unsupported_lang} ->
        send_resp(conn, 422, "unsupported lanugage: #{lang}")
    end
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
