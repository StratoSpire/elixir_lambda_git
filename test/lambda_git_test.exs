defmodule LambdaGitTest do
  use ExUnit.Case
  doctest LambdaGit

  test "intializes git" do
    assert LambdaGit.init() == {:ok, "/tmp/git"}
    assert System.get_env("GIT_TEMPLATE_DIR") == "/tmp/git/usr/share/git-core/template"
    assert System.get_env("GIT_EXEC_PATH") == "/tmp/git/usr/libexec/git-core"
    assert System.get_env("LD_LIBRARY_PATH") == "/tmp/git/usr/lib64"
    assert System.get_env("PATH") =~ "/tmp/git/usr/bin"
  end
end
