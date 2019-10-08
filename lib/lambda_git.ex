defmodule LambdaGit do
  @moduledoc """
  Module for deploying git for use in a Lambda.
  """

  @doc """
  Decompresses git and sets environement variables to enable its use.

  ## Examples

    iex> LambdaGit.init()
    {:ok, "/tmp/git"}

  """
  def init do
    base_dir = "/tmp/git"
    with :ok = extract(base_dir),
         :ok <- put_envs(base_dir) do
      {:ok, base_dir}
    end
  end

  def extract(base_dir) do
    :code.priv_dir(:lambda_git)
    |> Path.join("git-2.4.3.tar")
    |> :erl_tar.extract([{:cwd, base_dir}])
  end

  def put_envs(base_dir) do
    with :ok <- System.put_env("GIT_TEMPLATE_DIR", Path.join(base_dir, "usr/share/git-core/template")),
         :ok <- System.put_env("GIT_EXEC_PATH", Path.join(base_dir, "usr/libexec/git-core")),
         :ok <- System.put_env("LD_LIBRARY_PATH", Path.join(base_dir, "usr/lib64")),
         :ok <- System.put_env("PATH", System.get_env("PATH") <>":" <> Path.join(base_dir, "usr/bin")) do
      :ok
    end
  end
end
