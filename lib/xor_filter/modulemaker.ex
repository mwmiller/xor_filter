defmodule XorFilter.ModuleMaker do
  @moduledoc false
  defmacro gen_modules(main, app, sup, buckets) when buckets >= 1 do
    quote bind_quoted: binding() do
      defmodule app do
        @moduledoc false

        use Application

        def start(_type, _args) do
          children = []

          opts = [strategy: :one_for_one, name: unquote(sup)]
          Supervisor.start_link(children, opts)
        end
      end

      defmodule main do
        @moduledoc false
        require Blake2

        def start do
          require unquote(app)
          unquote(app).start([], [])
        end

        case {buckets, rem(256, buckets)} do
          # Always goes in the only bucket
          # Avoid the hashing overhead
          {1, 0} ->
            def bucket_for(_), do: 0

          # Figure out which bucket otherwise
          {_, n} ->
            def bucket_for(s) do
              pick = fn k, fun ->
                p = Blake2.hash2s(s, 1, k) |> :binary.decode_unsigned()

                cond do
                  # Avoid bias towards the smaller buckets by rejection sampling
                  # "A"... key is used here to get a different hashing from the fingerprint
                  # this should avoid bias in the set bits in the buckets as well
                  p < unquote(n) -> fun.(k <> "A", fun)
                  true -> p
                end
              end

              rem(pick.("A", pick), unquote(buckets))
            end
        end
      end
    end
  end
end
