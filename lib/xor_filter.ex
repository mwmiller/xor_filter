defmodule XorFilter do
  @moduledoc """
  Documentation for `XorFilter`.
  """
  require XorFilter.ModuleMaker

  @doc """
  Prepare an XOR filter application
  """
  @spec prepare(Keyword.t()) :: term
  def prepare(args \\ []) do
    {name, key_count, buckets} = parse_args!(args)
    main = Module.concat("XorFilter", name)
    sup = Module.concat(main, "Supervisor")
    work = Module.concat(main, "Bucket")
    XorFilter.ModuleMaker.gen_modules(main, sup, work, buckets, key_count)

    case Code.ensure_compiled(main) do
      {:module, module} -> module
      {:error, why} -> raise(why)
    end
  end

  defp parse_args!(args) do
    buckets = Keyword.get(args, :buckets, 1)

    if not is_integer(buckets) or buckets < 1 or buckets > 256,
      do: raise(RuntimeError, "must supply an integer on [1,256] for buckets")

    key_count = Keyword.get(args, :key_count, :math.pow(2, 32) |> trunc)

    if not is_integer(key_count) or key_count < 1,
      do: raise(RuntimeError, "must supply a positive integer for key_count")

    {Keyword.get(args, :name, Enum.join([buckets, key_count], "_")), key_count, buckets}
  end

  @doc """
  Prepare and start an XOR filter application
  """
  @spec start(Keyword.t()) :: {term, pid}
  def start(args \\ []) do
    mod = prepare(args)
    {:ok, pid} = mod.start([], [])
    {mod, pid}
  end
end
