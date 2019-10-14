defmodule LambdaGit do
  @moduledoc """
  Module for deploying git for use in a Lambda.
  """

  @doc """
  Decompresses git and sets environement variables to enable its use.

  ## Examples

    iex> LambdaGit.init()
    {:ok, %{template_dir: "/tmp/git/usr/share/git-core/templates", exec_path: "/tmp/git/usr/libexec/git-core", ld_library_path: "/tmp/git/usr/lib64", bin_path: "/tmp/git/usr/bin"}}

  """
  def init do
    if Application.get_env(:lambda_git, :enabled) do
      with {:ok, _} = extract(),
           :ok <- put_envs() do
        {
          :ok,
          %{
              template_dir: template_dir(),
              exec_path: exec_path(),
              ld_library_path: ld_library_path(),
              bin_path: bin_path()
          }
        }
      end
      |> case do
           {:ok, result} ->
             {:ok, result}

           other ->
             {:error, other}
         end
    else
      {:ok, nil}
    end
  end

  def extract do
    tar = Path.join([Application.app_dir(:lambda_git), "priv/git-2.4.3.tar"])
    File.mkdir_p(base_dir())
    case System.cmd("tar", ["-xf", tar, "-C", base_dir()]) do
      {out, 0} -> {:ok, out}
      {err, 1} -> {:error, err}
    end
  end

  def put_envs do
    with :ok <- System.put_env("GIT_TEMPLATE_DIR", template_dir()),
         :ok <- System.put_env("GIT_EXEC_PATH", exec_path()),
         :ok <- System.put_env("LD_LIBRARY_PATH", ld_library_path()),
         :ok <- System.put_env("PATH", path()) do
      :ok
    end
  end

  def base_dir, do: "/tmp/git"
  def template_dir, do: base_dir() |> Path.join("usr/share/git-core/templates")
  def exec_path, do: base_dir() |> Path.join("usr/libexec/git-core")
  def bin_path, do: base_dir() |> Path.join("usr/bin")
  def path, do: bin_path() |> build_path_var("PATH")

  def ld_library_path do
    base_dir()
    |> Path.join("usr/lib64")
    |> build_path_var("LD_LIBRARY_PATH")
  end

  defp build_path_var(path, var) do
    current = System.get_env(var)
    cond do
      current == nil ->
        path
      current |> String.contains?(path) ->
        current
      true ->
        current <> ":" <> path
    end
  end
end
