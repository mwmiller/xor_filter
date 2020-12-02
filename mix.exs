defmodule XorFilter.MixProject do
  use Mix.Project

  def project do
    [
      app: :xor_filter,
      version: "0.1.0",
      elixir: "~> 1.10",
      name: "XORFilter",
      source_url: "https://github.com/mwmiller/xor_filter",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end

  defp description do
    """
    XORFilter - probablistic set membership
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Matt Miller"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/mwmiller/xor_filter",
        "Whitepaper" => "https://arxiv.org/abs/1912.08258"
      }
    ]
  end
end
