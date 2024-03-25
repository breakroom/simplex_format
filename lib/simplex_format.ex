defmodule SimplexFormat do
  @moduledoc """
  Helpers related to formatting text.
  """

  import Phoenix.HTML, only: [html_escape: 1, safe_to_string: 1, raw: 1]
  import PhoenixHTMLHelpers.Tag, only: [content_tag: 3, tag: 1]

  @doc ~S"""
  Returns text transformed into HTML using simple formatting rules.

  Two or more consecutive newlines `\n\n` or `\r\n\r\n` are considered as a
  paragraph and text between them is wrapped in `<p>` tags.
  One newline `\n` or `\r\n` is considered as a linebreak and a `<br>` tag is inserted.

  ## Examples

      iex> text_to_html("Hello\n\nWorld") |> safe_to_string
      "<p>Hello</p>\n<p>World</p>\n"

      iex> text_to_html("Hello\nWorld") |> safe_to_string
      "<p>Hello<br>\nWorld</p>\n"

      iex> text_to_html("Hello, welcome to http://www.google.com", auto_link: true) |> safe_to_string
      "<p>Hello, welcome to <a href=\"http://www.google.com\">http://www.google.com</a></p>\n"

      iex> opts = [wrapper_tag: :div, attributes: [class: "p"]]
      ...> text_to_html("Hello\n\nWorld", opts) |> safe_to_string
      "<div class=\"p\">Hello</div>\n<div class=\"p\">World</div>\n"

  ## Options

    * `:escape` - if `false` does not html escape input (default: `true`)
    * `:wrapper_tag` - tag to wrap each paragraph (default: `:p`)
    * `:attributes` - html attributes of the wrapper tag (default: `[]`)
    * `:insert_brs` - if `true` insert `<br>` for single line breaks (default: `true`)
    * `:auto_link` - if `true` wrap HTTP URLs in an anchor tag (default: `false`)
    * `:url_attributes` - HTML attributes of the anchor tag for auto_linked URLs (default: `[]`)

  """
  @spec text_to_html(Phoenix.HTML.unsafe(), Keyword.t()) :: Phoenix.HTML.safe()
  def text_to_html(string, opts \\ []) do
    escape? = Keyword.get(opts, :escape, true)
    wrapper_tag = Keyword.get(opts, :wrapper_tag, :p)
    attributes = Keyword.get(opts, :attributes, [])
    insert_brs? = Keyword.get(opts, :insert_brs, true)
    auto_link? = Keyword.get(opts, :auto_link, false)
    url_attrs = Keyword.get(opts, :url_attributes, [])

    string
    |> maybe_html_escape(escape?)
    |> String.split(["\n\n", "\r\n\r\n"], trim: true)
    |> Enum.filter(&not_blank?/1)
    |> Enum.map(&wrap_paragraph(&1, wrapper_tag, attributes, insert_brs?, auto_link?, url_attrs))
    |> html_escape()
  end

  defp maybe_html_escape(string, true) do
    string
    |> html_escape()
    |> safe_to_string()
  end

  defp maybe_html_escape(string, false), do: string

  defp not_blank?("\r\n" <> rest), do: not_blank?(rest)
  defp not_blank?("\n" <> rest), do: not_blank?(rest)
  defp not_blank?(" " <> rest), do: not_blank?(rest)
  defp not_blank?(""), do: false
  defp not_blank?(_), do: true

  defp wrap_paragraph(text, tag, attributes, insert_brs?, auto_link?, url_attrs) do
    prepared_text =
      text
      |> insert_brs(insert_brs?)
      |> auto_link(auto_link?, url_attrs)

    [content_tag(tag, prepared_text, attributes), ?\n]
  end

  defp insert_brs(text, false) do
    text
    |> split_lines()
    |> Enum.intersperse(?\s)
    |> raw()
  end

  defp insert_brs(text, true) do
    text
    |> split_lines()
    |> Enum.map(&raw/1)
    |> Enum.intersperse([tag(:br), ?\n])
  end

  defp split_lines(text) do
    String.split(text, ["\n", "\r\n"], trim: true)
  end

  defp auto_link(lines, false, _), do: lines

  defp auto_link(lines, true, url_attrs) do
    assemble_links([], lines, url_attrs)
  end

  @url_regex ~r/((http(s)?(\:\/\/))+(www\.)?([\w\-\.\/])*(\.[a-zA-Z]{2,3}\/?))[^\s\b\n|]*[^.,;:\?\!\@\^\$ -]/

  defp assemble_links(runs, [], _), do: runs

  defp assemble_links(runs, [line | lines], url_attrs) when is_list(line) do
    assemble_links(runs ++ [line], lines, url_attrs)
  end

  defp assemble_links(runs, [line | lines], url_attrs) do
    text = safe_to_string(line)

    case url_indices(text) do
      nil ->
        assemble_links(runs ++ [line], lines, url_attrs)

      indices ->
        {leading, url, trailing} = split_at_indices(text, indices)
        safe_leading = raw(leading)
        safe_trailing = raw(trailing)
        safe_url = wrap_url(url, url_attrs)

        assemble_links(runs ++ [safe_leading, safe_url], [safe_trailing] ++ lines, url_attrs)
    end
  end

  defp url_indices(""), do: nil

  defp url_indices(text) do
    case Regex.run(@url_regex, text, return: :index, captures: :all_but_first) do
      nil -> nil
      matches -> matches |> Enum.at(0)
    end
  end

  defp split_at_indices(text, {index, split_length}) do
    leading = binary_part(text, 0, index)
    middle = binary_part(text, index, split_length)

    trailing_index = index + split_length
    trailing_length = byte_size(text) - trailing_index
    trailing = binary_part(text, trailing_index, trailing_length)

    {leading, middle, trailing}
  end

  defp wrap_url(url, url_attributes) do
    attributes = Keyword.merge(url_attributes, href: url)
    content_tag(:a, url, attributes)
  end
end
