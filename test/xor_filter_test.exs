defmodule XorFilterTest do
  use ExUnit.Case
  doctest XorFilter

  test "create test filter" do
    expected_mod = XorFilter.Prepare
    assert expected_mod == XorFilter.prepare(name: "Prepare")
    assert {:ok, pid} = expected_mod.start([], [])
    assert :erlang.is_pid(pid)
  end

  test "create and run a test filter" do
    assert {XorFilter.Start, pid} = XorFilter.start(name: "Start", buckets: 10)

    assert :erlang.is_pid(pid)
  end

  test "failure modes" do
    assert_raise RuntimeError,
                 "must supply an integer on [1,256] for buckets",
                 fn ->
                   XorFilter.prepare(name: "Broken", buckets: 0)
                 end

    assert_raise RuntimeError,
                 "must supply an integer on [1,256] for buckets",
                 fn ->
                   XorFilter.prepare(name: "Broken", buckets: -1)
                 end

    assert_raise RuntimeError,
                 "must supply an integer on [1,256] for buckets",
                 fn ->
                   XorFilter.prepare(name: "Broken", buckets: 1.0)
                 end

    assert_raise RuntimeError,
                 "must supply an integer on [1,256] for buckets",
                 fn ->
                   XorFilter.prepare(name: "Broken", buckets: "bucket_count")
                 end

    assert_raise RuntimeError,
                 "must supply an integer on [1,256] for buckets",
                 fn ->
                   XorFilter.prepare(name: "Broken", buckets: 257)
                 end

    assert_raise RuntimeError,
                 "must supply a positive integer for key_count",
                 fn ->
                   XorFilter.prepare(name: "Broken", buckets: 5, key_count: 0)
                 end

    assert_raise RuntimeError,
                 "must supply a positive integer for key_count",
                 fn ->
                   XorFilter.prepare(name: "Broken", buckets: 5, key_count: 3.1415)
                 end
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

    assert [
             :XorFilter_IP1_0,
             :XorFilter_IP1_0,
             :XorFilter_IP1_0,
             :XorFilter_IP1_0,
             :XorFilter_IP1_0
           ] = BucketList.generate("IP1", 1, test_strings)

    assert [
             :XorFilter_IP16_9,
             :XorFilter_IP16_14,
             :XorFilter_IP16_10,
             :XorFilter_IP16_7,
             :XorFilter_IP16_8
           ] = BucketList.generate("IP16", 16, test_strings)
  end

  test "usage" do
    # This module doesn't exist yet.
    # Referencing it directly inside here confuses the
    # test case writing macros and generates warnings
    mod = XorFilter.IP7

    test_strings = [
      "127.0.0.1",
      "::1",
      "192.168.0.1",
      "an IP",
      "a netmask"
    ]

    # These cross buckets.  But we don't want to pretest
    # so that we don't redefine on use here.
    assert {XorFilter.IP7, _pid} = XorFilter.start(name: "IP7", buckets: 7)
    refute mod.maybe_seen?("127.0.0.1")
    assert :ok = mod.seen("127.0.0.1")
    assert mod.maybe_seen?("127.0.0.1")
    assert [true, false, false, false, false] = mod.check_and_see(test_strings)
    assert [true, true, true, true, true] = mod.check_and_see(test_strings)
    assert [true, true, true, true, true] = mod.maybe_seen?(test_strings)
    assert [true, true, true, true, true] = mod.maybe_seen?(test_strings)
    refute mod.maybe_seen?("something else")

    assert [true, true, true, true, true, false] =
             mod.maybe_seen?(test_strings ++ ["something_else"])

    assert :ok = mod.seen("something else")

    assert [true, true, true, true, true, false] =
             mod.maybe_seen?(test_strings ++ ["something_else"])
  end
end
