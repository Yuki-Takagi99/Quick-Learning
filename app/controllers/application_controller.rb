class ApplicationController < ActionController::Base
  include ProjectAdminsHelper
  include ProjectUsersHelper
  # CSRF対策
  protect_from_forgery with: :exception
  # flashメッセージの
  add_flash_types :success, :info, :warning, :danger
  # ログイン済ユーザーのみにアクセスを許可する
  before_action :login_required
  # ログイン後、遷移先を分岐
  def after_sign_in_path_for(resource)
    case resource
    when Admin
      if admin_participation?
        admin_project
      elsif current_admin.invited_by_id.present?
        introduction_projects_path
      else
        new_project_path
      end
    when User
      unless user_project.present?
        introduction_projects_path
      else
        current_user
      end
    end
  end

  # deviseコントローラーにストロングパラメータを追加する
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def login_required
    redirect_to new_user_session_path unless current_user || current_admin
  end

# 以下設定途中
  # def admin_login_required
  #   redirect_back(fallback_location: root_path) unless current_admin
  # end

  protected

  def configure_permitted_parameters
    # サインアップ時にnameのストロングパラメータを追加
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    # アカウント編集の時にnameのストロングパラメータを追加
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
    devise_parameter_sanitizer.permit(:invite, keys: [:name])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
    # devise_invitableを使用する際に、他のモデルからでも招待ができるようにする
    def authenticate_inviter!
      authenticate_admin!(force: true)
    end
  end
end
