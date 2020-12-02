defmodule XorFilterTest do
  use ExUnit.Case
  doctest XorFilter

  test "Create test filter" do
    expected_mod = XorFilter.Prepare
    assert expected_mod == XorFilter.prepare("Prepare", 1)
    assert {:ok, pid} = expected_mod.start()
    assert :erlang.is_pid(pid)
  end

  test "Create and run a test filter" do
    assert {XorFilter.Start, pid} = XorFilter.start("Start", 10)
    assert :erlang.is_pid(pid)
  end
end
