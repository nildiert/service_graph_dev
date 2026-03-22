# frozen_string_literal: true

require_relative "../test_helper"
require_relative "../../app/services/service_graph_dev/mermaid_exporter"

class MermaidExporterTest < Minitest::Test
  def setup
    @services = {
      "UserCreator" => {
        class_name: "UserCreator",
        dependencies: ["DbLogger", "Messenger"]
      },
      "DbLogger" => {
        class_name: "DbLogger",
        dependencies: []
      },
      "Messenger" => {
        class_name: "Messenger",
        dependencies: ["SmsGateway"]
      },
      "SmsGateway" => {
        class_name: "SmsGateway",
        dependencies: []
      },
      "Notifier" => {
        class_name: "Notifier",
        dependencies: ["UserCreator"]
      }
    }
  end

  def test_mermaid_export_structure
    exporter = ServiceGraphDev::MermaidExporter.new(@services, "UserCreator", max_depth: 3)
    mermaid  = exporter.export

    # Should contain graph header
    assert_match(/graph TD/, mermaid)

    # Should contain nodes with classes
    assert_match(/UserCreator.*:::selected/, mermaid)
    assert_match(/DbLogger.*:::dependency/, mermaid)
    assert_match(/Messenger.*:::dependency/, mermaid)
    assert_match(/Notifier.*:::affected/, mermaid)

    # Should contain edges
    assert_match(/UserCreator --> DbLogger/, mermaid)
    assert_match(/UserCreator --> Messenger/, mermaid)
    assert_match(/Notifier --> UserCreator/, mermaid)
    
    # Should contain transitive dependencies (level 2)
    assert_match(/SmsGateway.*:::dependency/, mermaid)
    assert_match(/Messenger --> SmsGateway/, mermaid)
  end

  def test_mermaid_depth_limit
    # At depth 1, SmsGateway should not appear
    exporter = ServiceGraphDev::MermaidExporter.new(@services, "UserCreator", max_depth: 1)
    mermaid  = exporter.export

    assert_match(/Messenger/, mermaid)
    refute_match(/SmsGateway/, mermaid)
  end

  def test_mermaid_id_sanitization
    services = { "A::B::C" => { class_name: "A::B::C", dependencies: ["X::Y"] } }
    exporter = ServiceGraphDev::MermaidExporter.new(services, "A::B::C")
    mermaid  = exporter.export

    assert_match(/A_B_C\["A::B::C"\]/, mermaid)
    assert_match(/X_Y\["X::Y"\]/, mermaid)
  end
end
