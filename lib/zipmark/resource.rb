module Zipmark
  class Resource
    attr_accessor :options

    def initialize(options={})
      @options = Util.stringify_keys(options)
    end

    def all
      Zipmark::Collection.new(self, Zipmark::Iterator)
    end

    def find(id)
      response = client.get("/" + rel + "/" + id)
      object = JSON.parse(response.body)
      if client.successful?(response)
        Zipmark::Entity.new(object[resource_name].merge(:client => client, :resource_type => resource_name))
      else
        raise Zipmark::Error.new(!!object ? object.merge(:status => response.status) : response)
      end
    end

    def build(options)
      Zipmark::Entity.new(options.merge(:client => client, :resource_type => resource_name))
    end

    def create(options)
      entity = build(options)
      entity.save
    end

    def href
      options["href"] || raise(Zipmark::ResourceError, "Resource did not specify href")
    end

    def rel
      options["rel"] || raise(Zipmark::ResourceError, "Resource did not specify rel")
    end

    def resource_name
      #TODO: This is a hack
      rel.gsub(/s$/, '')
    end

    def client
      options["client"] || raise(Zipmark::ClientError, "You must pass :client as an option")
    end
  end
end
