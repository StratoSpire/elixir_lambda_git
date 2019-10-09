defmodule LambdaGitTest do
  use ExUnit.Case
  doctest LambdaGit

  test "intializes git" do
   template_dir = "/tmp/git/usr/share/git-core/templates"
   exec_path = "/tmp/git/usr/libexec/git-core"
   ld_library_path = "/tmp/git/usr/lib64"
   bin_path = "/tmp/git/usr/bin"

    assert LambdaGit.init() == {
      :ok,
      %{
        template_dir: template_dir,
        exec_path: exec_path,
        ld_library_path: ld_library_path,
        bin_path: bin_path
      }
    }

    assert System.get_env("GIT_TEMPLATE_DIR") == template_dir
    assert System.get_env("GIT_EXEC_PATH") == exec_path
    assert System.get_env("LD_LIBRARY_PATH") == ld_library_path
    assert System.get_env("PATH") =~ bin_path
  end
end
