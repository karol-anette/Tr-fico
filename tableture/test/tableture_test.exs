defmodule TablatureTest do
  use ExUnit.Case

  test "Ode to joy, part 1" do
    tab = """
          e|-------------------------------|
          B|-5-5-6-8-8-6-5-3-1-1-3-5-5-3-3-|
          G|-------------------------------|
          D|-------------------------------|
          A|-------------------------------|
          E|-------------------------------|
          """
    expected = "B5 B5 B6 B8 B8 B6 B5 B3 B1 B1 B3 B5 B5 B3 B3"
    assert Tablature.parse(tab) == expected
  end

  @tag :skip
  test "Ode to joy, part 2" do
    tab = """
          e|-------------------------------|
          B|-5-5-6-8-8-6-5-3-1-1-3-5-3-1-1-|
          G|-------------------------------|
          D|-------------------------------|
          A|-------------------------------|
          E|-------------------------------|
          """
    expected = "B5 B5 B6 B8 B8 B6 B5 B3 B1 B1 B3 B5 B3 B1 B1"
    assert Tablature.parse(tab) == expected
  end
end
