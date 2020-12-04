ExUnit.start()

defmodule BucketList do
  def generate(name, buckets, strings) do
    {mod, _pid} = XorFilter.start(name: name, buckets: buckets)
    convert(strings, mod, [])
  end

  def convert([], _mod, acc), do: Enum.reverse(acc)
  def convert([h | t], mod, acc), do: convert(t, mod, [mod.bucket_for(h) | acc])
end
