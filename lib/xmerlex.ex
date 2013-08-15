defmodule Xmerlex do
  @moduledoc """
             Simple wrapper around Erlangs xmerl XML facilities to ease common chores.
             """

  defmodule HTTP do
    defp get(url, user_agent) do
      case HTTPotion.get(url, [ "User-agent": user_agent ]) do
        HTTPotion.Response[body: body, status_code: status, headers: headers]
        when status in 200 .. 299 ->
          body
        HTTPotion.Response[body: body, status_code: status, headers: _headers] ->
          nil
      end
    end
  end

  defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")

  defrecord Node, xml: nil do
    def from_xmerl(xml), do: __MODULE__.new(xml: xml)

    def find(node, xpath) do
      :xmerl_xpath.string(to_char_list(xpath), node.xml)
        |> Enum.map __MODULE__.from_xmerl(&1)
    end

    def find_attribute(node, xpath) do
      :xmerl_xpath.string(xpath, node.xml)
        |> attribute_value
    end

    defp attribute_value([:xmlAttribute[value: value]]), do: :unicode.characters_to_binary(value)
    defp attribute_value(_), do: nil
  end

  def parse_string(nil), do: Node.new()
  def parse_string(xml_string) do
    { doc, _ } = :xmerl_scan.string(to_char_list(xml_string))
    Node.new(xml: doc)
  end

  def parse_file(filename) do
    { doc, _ } = :xmerl_scan.file(to_char_list(filename))
    Node.new(xml: doc)
  end

  def parse_url(url, user_agent), do: HTTP.get(url, user_agent) |> parse_string

end
