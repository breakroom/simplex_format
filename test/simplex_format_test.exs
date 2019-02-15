defmodule SimplexFormatTest do
  use ExUnit.Case, async: true

  import SimplexFormat
  import Phoenix.HTML

  doctest SimplexFormat

  test "wraps paragraphs" do
    formatted =
      format("""
      Hello,

      Please come see me.

      Regards,
      The Boss.
      """)

    assert formatted == """
           <p>Hello,</p>
           <p>Please come see me.</p>
           <p>Regards,<br>
           The Boss.</p>
           """
  end

  test "wraps paragraphs with carriage returns" do
    formatted = format("Hello,\r\n\r\nPlease come see me.\r\n\r\nRegards,\r\nThe Boss.")

    assert formatted == """
           <p>Hello,</p>
           <p>Please come see me.</p>
           <p>Regards,<br>
           The Boss.</p>
           """
  end

  test "escapes html" do
    formatted =
      format("""
      <script></script>
      """)

    assert formatted == """
           <p>&lt;script&gt;&lt;/script&gt;</p>
           """
  end

  test "skips escaping html" do
    formatted =
      format(
        """
        <script></script>
        """,
        escape: false
      )

    assert formatted == """
           <p><script></script></p>
           """
  end

  test "adds brs" do
    formatted =
      format("""
      Hello,
      This is dog,
      How can I help you?


      """)

    assert formatted == """
           <p>Hello,<br>
           This is dog,<br>
           How can I help you?</p>
           """
  end

  test "adds brs with carriage return" do
    formatted = format("Hello,\r\nThis is dog,\r\nHow can I help you?\r\n\r\n\r\n")

    assert formatted == """
           <p>Hello,<br>
           This is dog,<br>
           How can I help you?</p>
           """
  end

  test "doesnt add brs" do
    formatted =
      format(
        """
        Hello,
        This is dog,
        How can I help you?


        """,
        insert_brs: false
      )

    assert formatted == """
           <p>Hello, This is dog, How can I help you?</p>
           """
  end

  test "auto_link" do
    formatted =
      format(
        """
        You should try http://www.google.com
        It's pretty good.

        You should try it.
        """,
        auto_link: true
      )

    assert formatted == """
           <p>You should try <a href="http://www.google.com">http://www.google.com</a><br>\nIt&#39;s pretty good.</p>\n<p>You should try it.</p>
           """
  end

  test "auto_link with trailing punctuation" do
    formatted =
      format(
        """
        Have you seen http://www.google.com? It's pretty good.
        """,
        auto_link: true
      )

    assert formatted == """
           <p>Have you seen <a href="http://www.google.com">http://www.google.com</a>? It&#39;s pretty good.</p>
           """
  end

  test "auto_link with complex URL with a hash" do
    formatted =
      format(
        """
        Have you seen http://www.google.com/foo?bar=baz#foo? It's pretty good.
        """,
        auto_link: true
      )

    assert formatted == """
           <p>Have you seen <a href="http://www.google.com/foo?bar=baz#foo">http://www.google.com/foo?bar=baz#foo</a>? It&#39;s pretty good.</p>
           """
  end

  test "auto_link with url_attributes" do
    formatted =
      format(
        """
        Have you seen http://www.google.com/foo?bar=baz#foo? It's pretty good.
        """,
        auto_link: true,
        url_attributes: [class: "foo", target: "_blank"]
      )

    assert formatted == """
           <p>Have you seen <a class="foo" href="http://www.google.com/foo?bar=baz#foo" target="_blank">http://www.google.com/foo?bar=baz#foo</a>? It&#39;s pretty good.</p>
           """
  end

  test "auto_link with URL without a scheme isn't linked" do
    formatted =
      format(
        """
        Have you seen www.google.com? It's pretty good.
        """,
        auto_link: true
      )

    assert formatted == """
           <p>Have you seen www.google.com? It&#39;s pretty good.</p>
           """
  end

  defp format(text, opts \\ []) do
    text |> text_to_html(opts) |> safe_to_string
  end
end
