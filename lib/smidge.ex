defmodule Smidge do
  @moduledoc """
  Documentation for Smidge.
  """

  defstruct module: nil, fragments: MapSet.new()

  @doc """
  Returns an empty `Smidge` struct.

  ## Examples

      iex> Smidge.new(Foo)
      %Smidge{module: Foo}

  """
  def new(module) do
    %Smidge{module: module}
  end

  @doc """
  Changes the module that will be used to render the templates.

  ## Examples

      iex> Smidge.new(Foo) |> Smidge.set(Bar)
      %Smidge{module: Bar}

  """
  def set(%Smidge{} = smidge, module) do
    %{smidge | module: module}
  end

  @doc """
  Puts a fragment inside the `Smidge` struct.

  ## Examples

      Smidge.new(Foo) |> Smidge.put("_foo.html", foo: "foo")
      #=> %Smidge{module: Foo, fragments: [{Foo, "_foo.html", foo: "foo"}]}

  """
  def put(%Smidge{module: module, fragments: fragments} = smidge, template, assigns \\ []) do
    %{smidge | fragments: MapSet.put(fragments, {module, template, assigns})}
  end

  @doc """
  Merges two Smidges.

  ## Examples

      foo = Smidge.new(Foo) |> Smidge.put("_foo.html", foo: "foo")
      bar = Smidge.new(Bar) |> Smidge.put("_bar.html", bar: "bar")

      Smidge.merge(foo, bar)
      #=> %Smidge{module: nil, fragments: [{Foo, "_foo.html", foo: "foo"}, {Bar, "_bar.html", bar: "bar"}]}

  """
  def merge(%Smidge{} = lhs, %Smidge{} = rhs) do
    fragments = MapSet.union(lhs.fragments, rhs.fragments)
    %Smidge{module: nil, fragments: fragments}
  end

  @doc """
  Returns the Smidge as html content.

  ## Example

      Smidge.new(Foo)
      |> Smidge.put("_foo.html", foo: "foo")
      |> Smidge.content(smidge)
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()
      #=> "<template name=\"FooView:foo\" role=\"fragment\">foo</template>"

  """
  def content(%Smidge{fragments: fragments}) do
    Enum.map(fragments, fn {module, template, assigns} ->
      fragment(module, template, assigns)
    end)
  end

  defp fragment(module, template, assigns) do
    template
    |> module.render(assigns)
    |> fragment_tag(module, template)
  end

  defp fragment_tag(content, view, template) do
    resource = view.__resource__
    template = Path.rootname(template)
    attrs = [role: "fragment", name: "#{resource}:#{template}"]
    Phoenix.HTML.Tag.content_tag(:template, content, attrs)
  end
end

defimpl Phoenix.HTML.Safe, for: Smidge do
  def to_iodata(nil), do: ""

  def to_iodata(%Smidge{} = smidge) do
    smidge
    |> Smidge.content()
    |> Phoenix.HTML.html_escape()
  end
end
