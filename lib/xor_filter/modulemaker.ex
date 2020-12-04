defmodule XorFilter.ModuleMaker do
  @moduledoc false
  defmacro gen_modules(main, sup, work, buckets, key_count) do
    quote bind_quoted: binding() do
      defmodule main do
        @moduledoc false

        require Blake2
        use Application

        def start(_type, _args) do
          children =
            for n <- 0..(unquote(buckets) - 1) do
              %{
                id: n,
                start: {unquote(work), :start_link, [bucket_atom(n), MapSet.new()]},
                restart: :permanent
              }
            end

          opts = [strategy: :one_for_one, name: unquote(sup)]
          Supervisor.start_link(children, opts)
        end

        def check_and_see(items) do
          existed = maybe_seen?(items)
          seen(items)
          existed
        end

        def seen(items) when is_list(items), do: seen(items, [])
        defp seen([], acc), do: Enum.reverse(acc)
        defp seen([h | t], acc), do: seen(t, [seen(h) | acc])

        def seen(item), do: GenServer.cast(bucket_for(item), {:seen, item})

        def maybe_seen?(items) when is_list(items), do: maybe_seen?(items, [])

        defp maybe_seen?([], acc), do: Enum.reverse(acc)
        defp maybe_seen?([h | t], acc), do: maybe_seen?(t, [maybe_seen?(h) | acc])

        def maybe_seen?(item), do: GenServer.call(bucket_for(item), {:contains, item})

        mfa = main |> Module.split() |> Enum.map(&to_string/1)

        # Not existing atom, but we control the input
        # We also don't mind appending here for readability.
        def bucket_atom(n),
          do:
            (unquote(mfa) ++ [to_string(n)])
            |> Enum.join("_")
            |> String.to_atom()

        case {buckets, rem(256, buckets)} do
          # Always goes in the only bucket
          # Avoid the hashing overhead
          {1, 0} ->
            def bucket_for(_), do: bucket_atom(0)

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

              bucket_atom(rem(pick.("A", pick), unquote(buckets)))
            end
        end
      end

      defmodule work do
        use GenServer

        def start_link(name, state) do
          GenServer.start_link(__MODULE__, state, name: name)
        end

        @impl true
        def init(set) do
          {:ok, set}
        end

        @impl true
        def handle_call({:contains, item}, _from, set) do
          {:reply, MapSet.member?(set, item), set}
        end

        @impl true
        def handle_cast({:seen, item}, set) do
          {:noreply, MapSet.put(set, item)}
        end
      end
    end
  end
end
