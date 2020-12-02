defmodule XorFilter do
  @moduledoc """
  Documentation for `XorFilter`.
  """
  require XorFilter.ModuleMaker

  @doc """
  Prepare an XOR filter application
  """
  @spec prepare(String.t(), pos_integer) :: term
  def prepare(name, buckets \\ 1) do
    main = Module.concat("XorFilter", name)
    app = Module.concat(main, "Application")
    sup = Module.concat(main, "Supervisor")
    XorFilter.ModuleMaker.gen_modules(main, app, sup, buckets)

    case Code.ensure_compiled(main) do
      {:module, module} -> module
      {:error, why} -> raise(why)
    end
  end

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
