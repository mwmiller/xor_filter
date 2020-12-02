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
        def start do
          require unquote(app)
          unquote(app).start([], [])
        end
      end
    end
  end
end
