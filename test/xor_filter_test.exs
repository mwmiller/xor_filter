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

  test "bucket_for" do
    # This is more PropERly property testing.
    # Someday I will do that instead of using a test_helper here
    test_strings = [
      "127.0.0.1",
      "::1",
      "192.168.0.1",
      "an IP",
      "a netmask"
    ]

    assert [0, 0, 0, 0, 0] = BucketList.generate("IP1", 1, test_strings)
    assert [2, 0, 5, 4, 1] = BucketList.generate("IP7", 7, test_strings)
    assert [9, 14, 10, 7, 8] = BucketList.generate("IP16", 16, test_strings)
  end
end
