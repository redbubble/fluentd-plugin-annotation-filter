require 'fluent/test'
require 'fluent/test/driver/filter'
require "fluent/test/helpers"

require_relative "../../../lib/fluent/plugin/filter-kubernetes-annotation"

RSpec.configure do |c|
  c.include Fluent::Test::Helpers
end

describe Fluent::Plugin::KubernetesAnnotationFilter do
  let(:driver) { Fluent::Test::Driver::Filter.new(described_class).configure(conf) }

  before :all do
    Fluent::Test.setup
  end

  describe "configuration" do
    subject { driver.instance }

    context "with an empty config" do
      let(:conf) { "" }

      it "correctly defaults pass_through_events_without_kubernetes_tags to false" do
        expect(subject.pass_through_events_without_kubernetes_tags).to be(false)
      end
    end

    context "with pass_through_events_without_kubernetes_tags set to true" do
      let(:conf) { "pass_through_events_without_kubernetes_tags true" }

      it "correctly sets pass_through_events_without_kubernetes_tags" do
        expect(subject.pass_through_events_without_kubernetes_tags).to be(true)
      end
    end

    context "with pass_through_events_without_kubernetes_tags set to false" do
      let(:conf) { "pass_through_events_without_kubernetes_tags false" }

      it "correctly sets pass_through_events_without_kubernetes_tags" do
        expect(subject.pass_through_events_without_kubernetes_tags).to be(false)
      end
    end

    context "with a contains_container_name section" do
      let(:conf) {
        %[
          <contains_container_name>
          annotation llama
          </contains_container_name>
         ]
      }

      it "correctly sets containing_annotations" do
        expect(subject.containing_annotations).to eq(["llama"])
      end
    end

    context "with multiple contains_container_name sections" do
      let(:conf) {
        %[
          <contains_container_name>
          annotation llama
          </contains_container_name>

          <contains_container_name>
          annotation alpaca
          </contains_container_name>
         ]
      }

      it "correctly sets containing_annotations" do
        expect(subject.containing_annotations).to eq(["llama", "alpaca"])
      end
    end
  end

  describe "filtering records" do
    let (:records) {
      [
        { "message" => "log", "kubernetes" => { "container_name" => "llama", "annotations" => { "fluentd1" => "[\"llama\"]", "fluentd2" => "[\"llama\"]" } } },
        { "message" => "log-a-log", "kubernetes" => { "container_name" => "noannotations" } },
        { "message" => "log-a-log-a-log" },
        { "message" => "log2", "kubernetes" => { "container_name" => "llama", "annotations" => { "fluentd1" => "[\"llama\",\"alpaca\"]", "fluentd2" => "[\"alpaca\"]" } } }
      ]
    }

    subject {
      driver.run do
        records.each do |record|
          driver.feed("filter.test", event_time, record)
        end
      end

      driver.filtered_records
    }

    context "with an empty config" do
      let(:conf) { "" }

      it "drops all the records" do
        expect(subject).to eq([])
      end
    end

    context "with pass_through_events_without_kubernetes_tags set to true" do
      let(:conf) { "pass_through_events_without_kubernetes_tags true" }

      it "keeps the records without kubernetes tags" do
        expect(subject).to eq(records.values_at(1, 2))
      end
    end

    context "with pass_through_events_without_kubernetes_tags set to false" do
      let(:conf) { "pass_through_events_without_kubernetes_tags false" }

      it "drops all the records" do
        expect(subject).to eq([])
      end
    end

    context "with a contains_container_name section" do
      let(:conf) {
        %[
          <contains_container_name>
          annotation fluentd1
          </contains_container_name>
         ]
      }

      it "keeps records where the configured annotation contains the container name" do
        expect(subject).to eq(records.values_at(0, 3))
      end
    end

    context "with multiple contains_container_name sections" do
      let(:conf) {
        %[
          <contains_container_name>
          annotation fluentd1
          </contains_container_name>

          <contains_container_name>
          annotation fluentd2
          </contains_container_name>
         ]
      }

      it "keeps records where BOTH the configured annotations contain the container name" do
        expect(subject).to eq(records.values_at(0))
      end
    end

  end
end
