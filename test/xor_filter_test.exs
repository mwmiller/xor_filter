defmodule XorFilterTest do
  use ExUnit.Case
  doctest XorFilter

  test "create test filter" do
    expected_mod = XorFilter.Prepare
    assert expected_mod == XorFilter.prepare("Prepare", 1)
    assert {:ok, pid} = expected_mod.start()
    assert :erlang.is_pid(pid)
  end

  test "create and run a test filter" do
    assert {XorFilter.Start, pid} = XorFilter.start("Start", 10)
    assert :erlang.is_pid(pid)
  end

  test "failure modes" do
    assert_raise RuntimeError, "must supply a positive integer for buckets", fn ->
      XorFilter.prepare("Broken", 0)
    end

    assert_raise RuntimeError, "must supply a positive integer for buckets", fn ->
      XorFilter.prepare("Broken", -1)
    end

    assert_raise RuntimeError, "must supply a positive integer for buckets", fn ->
      XorFilter.prepare("Broken", 1.0)
    end

    assert_raise RuntimeError, "must supply a positive integer for buckets", fn ->
      XorFilter.prepare("Broken", "bucket_count")
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
             :XorFilter_IP7_2,
             :XorFilter_IP7_0,
             :XorFilter_IP7_5,
             :XorFilter_IP7_4,
             :XorFilter_IP7_1
           ] = BucketList.generate("IP7", 7, test_strings)

    assert [
             :XorFilter_IP16_9,
             :XorFilter_IP16_14,
             :XorFilter_IP16_10,
             :XorFilter_IP16_7,
             :XorFilter_IP16_8
           ] = BucketList.generate("IP16", 16, test_strings)
  end
end
