defmodule Tablature do
  def parse(tab) do
    Regex.scan(~r/\d+/, tab)
    |> List.flatten
    |> Enum.map(fn n -> "B" <> n end)
    |> Enum.join(" ")
  end
end
