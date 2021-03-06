require 'json'
require 'net/http'
require 'ostruct'
require 'pp'

-> {
  class Request
    def initialize(path, variable_bag, &block)
      @path = path
      @variable_bag = variable_bag
      @block = block
    end

    def uri
      url = @path.tap {|u| break "#{@variable_bag.base_url}#{u}" unless /\Ahttps?:/ === u }
      @uri ||= URI.parse(url)
    end

    def http_config(&block)
      tap { @http_config = block }
    end

    def invoke(request)
      request = request[uri.request_uri]
      http = Net::HTTP.new(uri.host, uri.port)

      if @variable_bag.default_request_config
        @variable_bag.default_request_config[request, http]
      end

      if @http_config
        @http_config[http]
      end

      if @block
        body = @variable_bag.instance_exec(request, http, &@block)
        if [Hash, Array].include?(body.class)
          request.body = body.to_json
          request['content-type'] = 'application/json'
        end
      end

      http.request(request)
    end
  end

  class Response
    def initialize(variable_bag, &block)
      @variable_bag = variable_bag
      @block = block
    end

    def invoke(response)
      response.instance_eval do
        begin
          @body = JSON.parse(@body, :object_class => OpenStruct)
        rescue JSON::ParserError
        end
      end

      @variable_bag.instance_exec(response, &@block)
    end
  end

  class HttpSession
    def initialize(variable_bag)
      @variable_bag = variable_bag
      @http_config = -> h {}
    end

    def request(path, &block)
      tap { @request = Request.new(path, @variable_bag, &block) }
    end

    def request_http_config(&block)
      tap { @request.http_config(&block) }
    end

    def response(&block)
      tap { @response = Response.new(@variable_bag, &block) }
    end
    alias_method :then, :response

    def do(request)
      response = @request.invoke(request)
      @response.invoke(response) if @response
    end
  end

  class VariableBag
    def method_missing(called_name, value = nil)
      if called_setter?(called_name)
        instance_variable_set(called_varName(called_name), value)
      else
        instance_variable_get(called_varName(called_name))
      end
    end

    private

    def called_varName(called_name)
      "@#{called_name.to_s.chomp('=')}".to_sym
    end

    def called_setter?(called_name)
      /=\z/ === called_name
    end
  end

  variable_bag = VariableBag.new

  String.class_eval do
    define_method :request do |&block|
      HttpSession.new(variable_bag).tap {|session| session.request(self, &block) }
    end
    alias_method :data, :request

    define_method :response do |&block|
      HttpSession.new(variable_bag)
        .tap {|session| session.request(self) }
        .tap {|session| session.response(&block) }
    end
    alias_method :then, :response
  end

  Kernel.module_eval do
    define_method :config do
      variable_bag
    end

    define_method :configure do |&block|
      variable_bag.instance_exec(&block)
    end

    define_method :GET do |session|
      session.do -> uri { Net::HTTP::Get.new(uri) }
    end

    define_method :POST do |session|
      session.do -> uri { Net::HTTP::Post.new(uri) }
    end

    define_method :PUT do |session|
      session.do -> uri { Net::HTTP::Put.new(uri) }
    end

    define_method :DELETE do |session|
      session.do -> uri { Net::HTTP::Delete.new(uri) }
    end
  end
}[]
