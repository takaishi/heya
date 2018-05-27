module Heya
  class Manager
    def apply(dryrun)
      client = k8s_client
      actual_namespaces = client.get_namespaces

      namespaces.each do |namespace|
        namespace.metadata.name
        if actual_namespaces.any?{|an| an.metadata.name == namespace.metadata.name}

          # 追加: 定義にあるけどクラスターにはない
          namespace.metadata.labels.to_h.keys.each do |key|
            an = actual_namespaces.find{|an| an.metadata.name == namespace.metadata.name}
            unless an.metadata.labels.to_h.has_key?(key)
              puts "#{namespace.metadata.name}にラベル #{key}: #{namespace.metadata.labels[key]}を追加"
            end
          end

          # 削除: 定義にないけどクラスターにはある
          an = actual_namespaces.find{|an| an.metadata.name == namespace.metadata.name}
          an.metadata.labels.to_h.keys.each do |key|
            unless namespace.metadata.labels.to_h.has_key?(key)
              puts "#{namespace.metadata.name}からラベル #{key}: #{an.metadata.labels[key]}を削除"
            end
          end

          # 更新定義にもクラスターにもあるけど値が違う
          namespace.metadata.labels.to_h.keys.each do |key|
            an = actual_namespaces.find{|an| an.metadata.name == namespace.metadata.name}
            if  an.metadata.labels.to_h.has_key?(key) && namespace.metadata.labels[key] != an.metadata.labels[key]
              puts "#{namespace.metadata.name}のラベルを更新 #{key}: #{namespace.metadata.labels[key]}"
            end
          end

          client.update_namespace(namespace) unless dryrun
        else
          puts "create: #{namespace.metadata.name}"
          client.create_namespace(namespace) unless dryrun
        end
      end

      actual_namespaces.each do |namespace|
        unless namespaces.any?{|ns| ns.metadata.name == namespace.metadata.name}
          puts "delete #{namespace.metadata.name}"
          client.delete_namespace(namespace.metadata.name) unless dryrun
        end
      end
    end

    def namespaces
      return @namespaces if @namespaces

      dsl = Heya::DSL.new
      dsl.read
      @namespaces = dsl.namespaces
    end

    def k8s_client
      config = Heya::Kubeconfig.new("#{ENV['HOME']}/.kube/config")

      ssl_options = {
          client_cert: OpenSSL::X509::Certificate.new(File.read(config.user_client_certificate)),
          client_key: OpenSSL::PKey::RSA.new(File.read(config.user_client_key)),
          ca_file: config.cluster_ca,
          verify_ssl:  OpenSSL::SSL::VERIFY_PEER
      }
      Kubeclient::Client.new(config.cluster_server, "v1", ssl_options: ssl_options)
    end
  end
end