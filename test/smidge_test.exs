defmodule SmidgeTest do
  use ExUnit.Case
  doctest Smidge

  defmodule FooView do
    def __resource__, do: "FooView"

    def render(_template, assigns) do
      {:safe, "#{assigns[:foo]}"}
    end
  end

  defmodule BarView do
    def __resource__, do: "BarView"

    def render(_template, assigns) do
      {:safe, "#{assigns[:bar]}"}
    end
  end

  test "new/1 returns an empty Smidge struct" do
    smidge = Smidge.new(FooView)
    refute is_nil(smidge)
    refute is_nil(smidge.module)
    assert smidge.fragments == MapSet.new()
  end

  test "put/2 puts a fragment with assigns" do
    smidge =
      FooView
      |> Smidge.new()
      |> Smidge.put("foo.html", foo: "foo")

    assert smidge.fragments == MapSet.new([{FooView, "foo.html", [foo: "foo"]}])
  end

  test "put/2 puts a fragment without assigns" do
    smidge =
      FooView
      |> Smidge.new()
      |> Smidge.put("foo.html")

    assert smidge.fragments == MapSet.new([{FooView, "foo.html", []}])
  end

  test "content/1 returns html content" do
    result =
      FooView
      |> Smidge.new()
      |> Smidge.put("foo.html", foo: "foo")
      |> Smidge.content()
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    assert result == "<div name=\"foo_view:foo\" role=\"fragment\">foo</div>"
  end

  test "set/1 changes current module" do
    result =
      FooView
      |> Smidge.new()
      |> Smidge.put("foo.html", foo: "foo")
      |> Smidge.set(BarView)
      |> Smidge.put("bar.html", bar: "bar")
      |> Smidge.content()
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    assert result ==
             "<div name=\"bar_view:bar\" role=\"fragment\">bar</div><div name=\"foo_view:foo\" role=\"fragment\">foo</div>"
  end

  test "merge/2 joins two Smidges" do
    foo_smidge =
      FooView
      |> Smidge.new()
      |> Smidge.put("foo.html", foo: "foo")

    bar_smidge =
      BarView
      |> Smidge.new()
      |> Smidge.put("bar.html", bar: "bar")

    result = Smidge.merge(foo_smidge, bar_smidge)

    assert result == %Smidge{
             fragments:
               MapSet.new([
                 {BarView, "bar.html", [bar: "bar"]},
                 {FooView, "foo.html", [foo: "foo"]}
               ]),
             module: nil
           }
  end

  test "to_iodata/1 transforms Smidge into iodata" do
    result =
      FooView
      |> Smidge.new()
      |> Smidge.put("foo.html", foo: "foo")
      |> Phoenix.HTML.Safe.to_iodata()
      |> Phoenix.HTML.safe_to_string()

    assert result == "<div name=\"foo_view:foo\" role=\"fragment\">foo</div>"
  end
end
