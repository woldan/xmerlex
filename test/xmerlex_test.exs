defmodule XmerlexTest do
  use ExUnit.Case

  defp create_simple_xml_string do
    "<foo><bar muh=\"maeh\" /><schnick a=\"b\"><schnack/></schnick></foo>"
  end

  defp create_simple_xml_character_list do
    '<foo><bar muh="maeh" /><schnick a="b"><schnack/></schnick></foo>'
  end

  defp create_xpath_test_xml do
    "<a>
      <b key1=\"needle\">
       <c key2=\"needle\">some text</c>
       <d key2=\"foo\" key1=\"bar\" />
      </b>
      <b key1=\"Needle\">
       <c key2=\"needle\" />
       <c key1=\"needle\">some text</c>
       <d key2=\"foo\" key1=\"bar\" />
      </b>
      <x key1=\"Needle\">
       <y key2=\"needle\">the text of the y element</y>
      </x>
     </a>"
  end

  test "XML data can be parsed from strings" do
    xml = create_simple_xml_string |> Xmerlex.parse_string
    assert(xml)
  end

  test "XML data can be parsed from character list" do
    xml = create_simple_xml_character_list |> Xmerlex.parse_string
    assert(xml)
  end

  test "XML data can be parsed from files" do
    success = File.write("out.xml", create_simple_xml_string())
    assert(success == :ok)
    xml = Xmerlex.parse_file("out.xml")
    assert(xml)
  end

  test "XPath queries written as strings yield parts of XML trees" do
    xml = create_xpath_test_xml |> Xmerlex.parse_string
    assert(xml)
    assert(Enum.count(Xmerlex.Node.find(xml, "//b")) == 2)
    assert(Enum.count(Xmerlex.Node.find(xml, "//c")) == 3)
    recall = Xmerlex.Node.find(xml, "//x") |> Enum.map Xmerlex.Node.find(&1, "//y")
    assert(Enum.count(recall) == 1)
  end

  test "XPath queries written as character lists yield parts of XML trees" do
    xml = create_xpath_test_xml |> Xmerlex.parse_string
    assert(xml)
    assert(Enum.count(Xmerlex.Node.find(xml, '//b')) == 2)
    assert(Enum.count(Xmerlex.Node.find(xml, '//c')) == 3)
    recall = Xmerlex.Node.find(xml, '//x') |> Enum.map Xmerlex.Node.find(&1, '//y')
    assert(Enum.count(recall) == 1)
  end

  test "XPath queries asserting on axes yield parts of XML trees" do
    xml = create_xpath_test_xml |> Xmerlex.parse_string
    assert(xml)
    assert(Enum.count(Xmerlex.Node.find(xml, '//*[@key1="needle"]')) == 2)
    assert(Enum.count(Xmerlex.Node.find(xml, '//*[@key2="needle"]')) == 3)
    assert(Enum.count(Xmerlex.Node.find(xml, '//*[@key2="needle"][../@key1="needle"]')) == 1)
  end

  test "XML attribute values can be found using XPath queries" do
    xml = create_xpath_test_xml |> Xmerlex.parse_string
    assert(xml)
    assert(Xmerlex.Node.find(xml, '//x') |> Enum.map(Xmerlex.Node.find_attribute(&1, './@key1')) == [["Needle"]])
    assert(Xmerlex.Node.find(xml, '//x') |> Enum.map(Xmerlex.Node.find_attribute(&1, './@key2')) == [[]])
    assert(Xmerlex.Node.find(xml, '//b') |> Enum.map(Xmerlex.Node.find_attribute(&1, './@key1')) == [["needle"],["Needle"]])
    assert(Xmerlex.Node.find(xml, '//b') |> Enum.map(Xmerlex.Node.find_attribute(&1, './@key2')) == [[],[]])
    assert(Xmerlex.Node.first(xml, '//x') |> Xmerlex.Node.find_attribute('./@key1') == ["Needle"])
    assert(Xmerlex.Node.first(xml, '//x') |> Xmerlex.Node.find_attribute('./@key2') == [])
    assert(Xmerlex.Node.first(xml, '//b') |> Xmerlex.Node.find_attribute('./@key1') == ["needle"])
    assert(Xmerlex.Node.first(xml, '//b') |> Xmerlex.Node.find_attribute('./@key2') == [])
    assert(Xmerlex.Node.find_attribute(xml, '//b/@key1') == ["needle","Needle"])
    assert(Xmerlex.Node.first_attribute(xml, '//b/@key1') == "needle")
    assert(Xmerlex.Node.find_attribute(xml, '//b/@key2') == [])
    assert(Xmerlex.Node.first_attribute(xml, '//b/@key2') == nil)
    assert(Xmerlex.Node.find_attribute(xml, '//c[@key1="needle"]/../@key1') == ["Needle"])
    assert(Xmerlex.Node.first_attribute(xml, '//c[@key1="needle"]/../@key1') =="Needle")
    assert(Xmerlex.Node.find_attribute(xml, "//b/@key1") == ["needle","Needle"])
    assert(Xmerlex.Node.first_attribute(xml, "//b/@key1") == "needle")
    assert(Xmerlex.Node.find_attribute(xml, "//b/@key2") == [])
    assert(Xmerlex.Node.first_attribute(xml, "//b/@key2") == nil)
    assert(Xmerlex.Node.find_attribute(xml, "//c[@key1=\"needle\"]/../@key1") == ["Needle"])
    assert(Xmerlex.Node.first_attribute(xml, "//c[@key1=\"needle\"]/../@key1") == "Needle")
  end

  test "XML element texts can be found using XPath queries" do
    xml = create_xpath_test_xml |> Xmerlex.parse_string
    assert(xml)
    assert(Xmerlex.Node.find_text(xml, '//c') == [ "some text", "some text" ])
    assert(Xmerlex.Node.first_text(xml, '//c') == "some text")
    assert(Xmerlex.Node.find_text(xml, '//y') == [ "the text of the y element" ])
    assert(Xmerlex.Node.first_text(xml, '//y') == "the text of the y element")
    assert(Xmerlex.Node.find_text(xml, '//*[@key2="needle"]') == [ "some text", "the text of the y element" ])
    assert(Xmerlex.Node.first_text(xml, '//*[@key2="needle"]') == "some text")
  end
end
