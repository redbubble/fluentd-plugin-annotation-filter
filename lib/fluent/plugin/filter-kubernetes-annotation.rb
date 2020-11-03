require "json"
require "fluent/plugin/filter"

module Fluent
  module Plugin
    class KubernetesAnnotationFilter < Filter
      Fluent::Plugin.register_filter("kubernetes_annotation", self)

      attr_reader :containing_annotations

      def initialize
        super
      end

      config_param :pass_through_events_without_kubernetes_tags, :bool, default: false

      config_section :contains_container_name, param_name: :contains_sections, multi: true do
        desc "The name of the Kuberntes annotation that must contain the value in the value field"
        config_param :annotation, :string
      end

      def configure(conf)
        super

        @containing_annotations = @contains_sections.map(&:annotation)
      end

      def filter(_, _, record)
        begin
          if(record.has_key?("kubernetes") && record["kubernetes"].has_key?("annotations"))
            unless annotations_contain_container_name?(record)
              return nil
            end
          elsif(!@pass_through_events_without_kubernetes_tags)
            return nil
          end

        rescue => e
          log.warn "failed to filter by kubernetes annotation", error: e
          log.warn_backtrace
        end

        return record
      end

      private

      def annotations_contain_container_name?(record)
        return false if containing_annotations.size == 0

        container_name = record['kubernetes']['container_name']

        containing_annotations.all? { |annotation|
          content = record["kubernetes"]["annotations"][annotation]

          if(content)
            JSON.parse(content)&.include?(container_name)
          end
        }
      end
    end
  end
end
