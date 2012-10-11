# coding: utf-8

class UsersController < ApplicationController

  before_filter :find_user, :only => [:show]
  
  def show
    @topics = @user.topics.includes(:tv_drama).desc('created_at').paginate(:page => params[:page], :per_page => 15)
  end

  def create
    user = User.new(params[:user])
    if user.save
      self.current_user = user
      user.update_attribute(:last_signed_in_at, Time.now)
      redirect_to :root
    else
      flash[:error] = user.errors.full_messages
      redirect_to :back
    end
  end

  def notifications
    @user = current_user
    @notifications = @user.notifications.desc('created_at').paginate(:page => params[:page], :per_page => 15)
    @user.read_notifications(@notifications)
  end

  private

  def find_user
    # 处理 login 有大写字母的情况
    if params[:id] != params[:id].downcase
      redirect_to request.path.downcase, :status => 301
      return
    end

    @user = User.where(:login => /^#{params[:id]}$/i).first
    render_404 if @user.nil?
  end  

end