module Heya
  class Kubeconfig

    def initialize(path)
      @path = path
      @kubeconfig ||= YAML.load_file(path)
    end

    def current_context
      @kubeconfig['current-context']
    end

    def context
      @kubeconfig['contexts'].find{|context| context['name'] == current_context}
    end

    def cluster
      @kubeconfig['clusters'].find{|cluster| cluster['name'] == context['name']}
    end

    def user
      @kubeconfig['users'].find{|user|user['name'] == context['context']['user']}
    end

    def cluster_server
      cluster['cluster']['server']
    end

    def cluster_ca
      cluster['cluster']['certificate-authority']
    end

    def user_client_certificate
      user['user']['client-certificate']
    end

    def user_client_key
      user['user']['client-key']
    end
  end
end