require "openssl"
require "socket"
require "uri"
require "cgi"
require "base64"
require "../common"

class HTTP::Client
  getter host
  getter port
  getter? ssl

  def initialize(@host, port = nil, @ssl = false)
    @port = port || (ssl ? 443 : 80)
  end

  def self.new(host, port = nil, ssl = false)
    client = new(host, port, ssl)
    begin
      yield client
    ensure
      client.close
    end
  end

  def basic_auth(username, password)
    header = "Basic #{Base64.strict_encode64("#{username}:#{password}")}"
    before_request do |request|
      request.headers["Authorization"] = header
    end
  end

  def before_request(&@before_request : HTTP::Request ->)
  end

  {% for method in %w(get post put head delete patch) %}
    def {{method.id}}(path, headers = nil, body = nil)
      exec {{method.upcase}}, path, headers, body
    end

    def {{method.id}}(path, headers = nil, body = nil)
      exec {{method.upcase}}, path, headers, body do |response|
        yield response
      end
    end

    def self.{{method.id}}(url, headers = nil, body = nil)
      exec {{method.upcase}}, url, headers, body
    end

    def self.{{method.id}}(url, headers = nil, body = nil)
      exec {{method.upcase}}, url, headers, body do |response|
        yield response
      end
    end
  {% end %}

  def post_form(path, form : String, headers = nil)
    headers ||= HTTP::Headers.new
    headers["Content-type"] = "application/x-www-form-urlencoded"
    post path, headers, form
  end

  def post_form(path, form : Hash, headers = nil)
    body = CGI.build_form do |form_builder|
      form.each do |key, value|
        form_builder.add key, value
      end
    end

    post_form path, body, headers
  end

  def exec(request : HTTP::Request)
    request.headers["User-agent"] ||= "Crystal"
    request.to_io(socket)
    socket.flush
    HTTP::Response.from_io(socket).tap do |response|
      close unless response.keep_alive?
    end
  end

  def exec(request : HTTP::Request, &block)
    request.headers["User-agent"] ||= "Crystal"
    request.to_io(socket)
    socket.flush
    HTTP::Response.from_io(socket) do |response|
      value = yield response
      response.body_io.try &.close
      close unless response.keep_alive?
      value
    end
  end

  def exec(method : String, path, headers = nil, body = nil)
    exec new_request method, path, headers, body
  end

  def exec(method : String, path, headers = nil, body = nil)
    exec(new_request(method, path, headers, body)) do |response|
      yield response
    end
  end

  def close
    @ssl_socket.try &.close
    @ssl_socket = nil

    @socket.try &.close
    @socket = nil
  end

  private def new_request(method, path, headers, body)
    headers ||= HTTP::Headers.new
    headers["Host"] ||= host_header
    request = HTTP::Request.new method, path, headers, body
    @before_request.try &.call(request)
    request
  end

  private def socket
    socket = @socket ||= TCPSocket.new @host, @port
    socket.sync = false
    if @ssl
      @ssl_socket ||= OpenSSL::SSL::Socket.new(socket)
    else
      socket
    end
  end

  private def host_header
    if (@ssl && @port != 443) || (!@ssl && @port != 80)
      "#{@host}:#{@port}"
    else
      @host
    end
  end

  def self.post_form(url, form, headers = nil)
    exec(url) do |client, path|
      client.post_form(path, form, headers)
    end
  end

  def self.exec(method, url, headers = nil, body = nil)
    exec(url) do |client, path|
      client.exec method, path, headers, body
    end
  end

  def self.exec(method, url, headers = nil, body = nil)
    exec(url) do |client, path|
      client.exec(method, path, headers, body) do |response|
        yield response
      end
    end
  end

  private def self.exec(url)
    uri = URI.parse(url)
    unless uri.scheme
      raise ArgumentError.new %(Request URI must have schema. Possibly add "http://" to the request URI?)
    end

    host = uri.host.not_nil!
    port = uri.port
    path = uri.full_path
    user = uri.user
    password = uri.password
    ssl = false

    case uri.scheme
    when "http"
      # Nothing
    when "https"
      ssl = true
    else
      raise "Unsuported scheme: #{uri.scheme}"
    end

    HTTP::Client.new(host, port, ssl) do |client|
      if user && password
        client.basic_auth(user, password)
      end
      yield client, path
    end
  end
end
