class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
    pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    !!@pattern.match(req.path.downcase.to_sym)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    @pattern.match(req.path.downcase.to_sym)
    route_params = {}
    @pattern.named_captures.each { |k,v| route_params[k] = v[0] }
    controller = @controller_class.new(req, res, route_params)
    controller.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    route = Route.new(
      pattern,
      method,
      controller_class,
      action_name
    )
    @routes << route
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    instance_eval { method }
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller, action|
      add_route(pattern, http_method, controller, action)
    end
  end

  # should return the route that matches this request
  def match(req)
    @routes.each do |route|
      return route if route.pattern.is_a?(Regexp) &&
                      route.pattern.match(req.path)
    end

    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    if route = match(req)
      route.run(req, res)
    else
      res.status = 404
    end
  end
end
