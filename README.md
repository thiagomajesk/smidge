# Smidge

A small lib that allows html templates to be combined in a single response.
 
If you are using [unpoly](https://unpoly.com), chances are you will want to use Smidge to combine and return multiple html fragments to your frontend for [`up.replace`](https://unpoly.com/up.replace) optimizations.

## Installation

```elixir
def deps do
  [
    {:smidge, github: "thiagomajesk/smidge"}
  ]
end
```

## Usage

```elixir
View
|> Smidge.new()
|> Smidge.put("_form.html", changeset: changeset)
|> Smidge.put("_sidebar.html", categories: categories)
|> Smidge.put("_topbar.html", user_info: user_info)
|> Smidge.content()
```

> Will return a safe string that you can return on your response.   
> Similar to how [Phoenix.HTML.Tag.content_tag/2](https://hexdocs.pm/phoenix_html/Phoenix.HTML.Tag.html#content_tag/2) works.

```html
<template name="FooView:_form" role="fragment">
  <form>
      <!-- [...] -->
  </form>  
</template>
<template name="FooView:_sidebar" role="fragment">
  <aside>
      <!-- [...] -->
  <aside>
</template>
<template name="FooView:_topbar" role="fragment">
  <nav>
      <!-- [...] -->
  <nav>
</template>
```
