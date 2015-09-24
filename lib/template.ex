defmodule Template do
  def render(page) do
    case File.read("posts/#{page}.md") do
      {:ok, markdown} -> {:ok, parse_markdown(markdown) |> render_layout}
      {:error, error} -> {:error, error}
    end
  end

  def parse_markdown(markdown) do
    markdown |> Earmark.to_html(%Earmark.Options{smartypants: false})
  end

  def render_layout(inner) do
    EEx.eval_file("web/templates/layout/main.html.eex", assigns: [inner: inner])
  end
end