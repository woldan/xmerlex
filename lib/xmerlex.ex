defmodule Xmerlex do
  @moduledoc """
             Simple wrapper around Erlangs xmerl XML facilities to ease common chores.
             """

  defmodule HTTP do
    @moduledoc "HTTPotion for the very lazy."
    
    @doc "HTTP.GET the body referred to by url or return nil."
    def get(url, user_agent) do
      case HTTPotion.get(url, [ "User-agent": user_agent ]) do
        HTTPotion.Response[body: body, status_code: status, headers: _headers]
        when status in 200 .. 299 ->
          body
        HTTPotion.Response[body: _body, status_code: _status, headers: _headers] ->
          nil
      end
    end
  end

  defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  defrecord Node, xml: nil do
    @doc "Converts the specified xmerl structure to a Node record."
    def from_xmerl(xml), do: __MODULE__.new(xml: xml)

    @doc "Finds the Node list matching the specified xpath_query using node as current node."
    def find(node, xpath_query) do
      :xmerl_xpath.string(to_char_list(xpath_query), node.xml)
        |> Enum.map &__MODULE__.from_xmerl(&1)
    end
    @doc "Finds only the ifirst Node matching the specified xpath_query using node as current node."
    def first(node, xpath_query), do: find(node, xpath_query) |> List.first

    @doc "Finds the value of the attribute matching the specified xpath_query using node as current node."
    def find_attribute(node, xpath_query) do
      :xmerl_xpath.string(to_char_list(xpath_query), node.xml)
        |> Enum.map &attribute_value(&1)
    end
    @doc "Finds only the value of the first attribute matching the specified xpath_query using node as current node."
    def first_attribute(node, xpath_query), do: find_attribute(node, xpath_query) |> List.first

    @doc "Finds the text of the Nodes matching the specified xpath_query using node as current node."
    def find_text(node, xpath_query) do
      query = to_string(xpath_query) <> "/text()"
      :xmerl_xpath.string(to_char_list(query), node.xml)
        |> Enum.map &text_value(&1)
    end
    @doc "Finds only the text of the first element matching the specified xpath_query using node as current node."
    def first_text(node, xpath_query), do: find_text(node, xpath_query) |> List.first

    defp attribute_value(:xmlAttribute[value: value]), do: to_string(value)
    defp attribute_value(_), do: nil
    defp text_value(:xmlText[value: value]), do: to_string(value)
    defp text_value(_), do: nil
  end

  @doc "Returns an empty Node."
  def parse_string(nil), do: Node.new()
  @doc "Returns the XML node containing the parsed xml_string."
  def parse_string(xml_string) do
    { doc, _ } = :xmerl_scan.string(to_char_list(xml_string))
    Node.new(xml: doc)
  end

  @doc "Returns the XML node containing the contents of file file_name."
  def parse_file(file_name) do
    { doc, _ } = :xmerl_scan.file(to_char_list(file_name))
    Node.new(xml: doc)
  end

  @doc "Returns the XML node containing the body of the HTTP.GET request for url."
  def parse_url(url, user_agent), do: HTTP.get(url, user_agent) |> parse_string

end
