class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_tenant

  #around_filter :user_time_zone

  before_filter do
    gon.resource = nil
  end

  # set_current_tenant
  before_filter do

    company = Company.where(subdomain: request.subdomains.last).first
    if subdomain_present? && !company.nil?
      ActsAsTenant.current_tenant = company
      logger.warn "subdomain_present? && company exists"
    elsif current_user_present?
      ActsAsTenant.current_tenant = current_user.company
      logger.warn "current_user_present? : #{current_user.name}"
      redirect_to root_url(subdomain: ActsAsTenant.current_tenant.subdomain)
    elsif !subdomain_present? || request.subdomains.last == 'www'
      logger.warn "user wanna sign up"
    else
      #ActsAsTenant.current_tenant = nil
      logger.warn "nothing : #{ActsAsTenant.current_tenant}"
      render :file => 'public/404.html', :status => :not_found, :layout => false
    end
  end


  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def subdomain_present?
    !request.subdomains.last.nil?
  end

  def current_user_present?
    !current_user.nil?
  end

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
    if current_user && current_user.company
      @notifications = current_user.try(:company).try(:alarm_notifications).where(archived: false)
      if @notifications.nil?
        return Array.new
      end
    end
  end

  def test_exception_notifier
    raise 'This is for testing exception notification gem.'
  end

  layout :guest_user_layout

  private

    def user_time_zone(&block)
      if current_user && !current_user.company.nil? && !current_user.company.time_zone.nil?
        Time.use_zone(current_user.company.time_zone, &block)
      else
        Time.use_zone("UTC", &block)
      end      
    end

    def guest_user_layout
      if current_user.nil?
        "guest"
      else
        "application"
      end
    end

    def current_tenant
      ActsAsTenant.current_tenant
    end

end
