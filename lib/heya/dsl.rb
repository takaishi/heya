module Heya
  class DSL
    attr_reader :namespaces

    def initialize
      @namespaces = []
    end

    def labels(param)
      param
    end

    def namespace(name, &block)
      params = block.call
      annotations = {
          "kubectl.kubernetes.io/last-applied-configuration" => {
              apiVersion: 'v1',
              kind: 'Namespace',
              metadata: {
                  annotations: {},
                  labels: params,
                  name: name,
                  namespace: ''
              }
          }.to_json
      }
      @namespaces << Kubeclient::Resource.new({metadata: {name: name, labels: params, annotations: annotations}})
    end

    def read
      open('./Heyafile') do |f|
        eval(f.read, binding)
      end
    end
  end
end