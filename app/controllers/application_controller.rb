class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  set_current_tenant_by_subdomain(:company, :subdomain)

  # cancan
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  # devise
  before_filter do
		resource = controller_name.singularize.to_sym
		method = "#{resource}_params"
		params[resource] &&= send(method) if respond_to?(method, true)
	end

  before_filter do 
    if current_user
      @notifications = User.find(current_user.id).mailbox.notifications
    end
  end

  layout :another_by_method

  def test_exception_notifier
    raise 'This is a test. This is only a test.'
  end

  private

    def another_by_method
      if current_user.nil?
        "guest"
      else
        "application"
      end
    end

end
