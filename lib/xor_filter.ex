defmodule XorFilter do
  @moduledoc """
  Documentation for `XorFilter`.
  """
  require XorFilter.ModuleMaker

  @doc """
  Prepare an XOR filter application
  """
  @spec prepare(String.t(), pos_integer) :: term
  def prepare(name, buckets \\ 1)

  def prepare(name, buckets) when is_integer(buckets) and buckets >= 1 and buckets <= 256 do
    main = Module.concat("XorFilter", name)
    app = Module.concat(main, "Application")
    sup = Module.concat(main, "Supervisor")
    work = Module.concat(main, "Bucket")
    XorFilter.ModuleMaker.gen_modules(main, app, sup, work, buckets)

    case Code.ensure_compiled(main) do
      {:module, module} -> module
      {:error, why} -> raise(why)
    end
  end

  def prepare(_, _), do: raise(RuntimeError, "must supply an integer on [1,255] for buckets")

  @doc """
  Prepare and start an XOR filter application
  """
  @spec start(String.t(), pos_integer) :: {term, pid}
  def start(name, buckets \\ 1) do
    mod = prepare(name, buckets)
    {:ok, pid} = mod.start()
    {mod, pid}
  end
end
