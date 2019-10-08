defmodule LambdaGit do
  @moduledoc """
  Module for deploying git for use in a Lambda.
  """

  @doc """
  Decompresses git and sets environement variables to enable its use.

  ## Examples

    iex> LambdaGit.init()
    {:ok, %{template_dir: "/tmp/git/usr/share/git-core/template", exec_path: "/tmp/git/usr/libexec/git-core", ld_library_path: "/tmp/git/usr/lib64", bin_path: "/tmp/git/usr/bin"}}

  """
  def init do
    if Application.get_env(:lambda_git, :enabled) do
      with :ok = extract(),
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
    else
      {:ok, nil}
    end
  end

  def extract do
    :code.priv_dir(:lambda_git)
    |> Path.join("git-2.4.3.tar")
    |> :erl_tar.extract([{:cwd, base_dir()}])
  end

  def put_envs do
    with :ok <- System.put_env("GIT_TEMPLATE_DIR", template_dir()),
         :ok <- System.put_env("GIT_EXEC_PATH", exec_path()),
         :ok <- System.put_env("LD_LIBRARY_PATH", ld_library_path()),
         :ok <- System.put_env("PATH", System.get_env("PATH") <>":" <> bin_path()) do
      :ok
    end
  end

  def base_dir, do: "/tmp/git"
  def template_dir, do: base_dir() |> Path.join("usr/share/git-core/template")
  def exec_path, do: base_dir() |> Path.join("usr/libexec/git-core")
  def ld_library_path, do: base_dir() |> Path.join("usr/lib64")
  def bin_path, do: base_dir() |> Path.join("usr/bin")
end
