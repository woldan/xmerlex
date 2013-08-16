# Xmerlex

Simple [Elixir](http://elixir-lang.org/) wrapper offering basic XML handling.
This is not a fully featured XML workbench (look for [xmerl](http://www.erlang.org/doc/apps/xmerl/)
itself) but tries to hide the details of the [Erlang bridging](http://elixir-lang.org/crash-course.html).

Parts of this code are inspired by https://gist.github.com/sasa1977/5967224

## Dependencies

Currently this depends on [HTTPotion](https://github.com/myfreeweb/httpotion) for HTTP client functionality.
Details on how to include it are collected [here](http://expm.co/httpotion).

## Build

1. Install [Elixir](http://elixir-lang.org/)
2. `cd <sources>` (change to where you downloaded this)
2. `mix deps.get`
4. `mix test`

## Usage

E.g. launch `iex -S mix` and use it like this:

    doc = Xmerlex.parse_url "http://musicbrainz.org/ws/2/discid/38WGPaAUUuF7B.Jnz1Bu9uOb17U-", "elixir"

    doc |> Xmerlex.Node.find("//release") |> Enum.count
    doc |> Xmerlex.Node.find_attribute '//release/@id'
    doc |> Xmerlex.Node.first_text '//release/title'
