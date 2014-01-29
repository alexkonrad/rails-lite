require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Already rendered" if already_rendered?

    @res.content_type = type
    @res.body = content

    self.session.store_session(@res)

    @already_built_response = :once
  end

  # helper method to alias @already_rendered
  def already_rendered?
    !!@already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    raise "Already rendered" if already_rendered?
    @res.status = 302
    @res["location"] = url

    session.store_session(@res)

    @already_built_response = :once
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
  render_content(
    ERB.new(
      File.read(
        "views/#{self.class.name.underscore}/#{template_name}.html.erb"
      )
    ).result(binding),
    "text/html"
  )
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end
