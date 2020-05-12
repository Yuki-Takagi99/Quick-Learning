class QuestionsController < ApplicationController
  skip_before_action :admin_login_required
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :set_part, only: [:create, :new]
# 例としてjoinsとeager_loadを使っている。違いを調べよ。
  def index
    if admin_signed_in?
      @search = Question.joins(part: [subject: :project]).where(projects: {id: admin_project.id}).ransack(params[:q])
      @questions = @search.result.order(created_at: :desc)
    end
    if user_signed_in?
      @search = Question.eager_load(part: [subject: :project]).where(projects: {id: user_project.id}).ransack(params[:q])
      @questions = @search.result.order(created_at: :desc)
    end
  end

  def new
    @question = Question.new
  end

  def create
    @question = @part.questions.build(question_params)
    @question.user_id = current_user.id
    if @question.save
      redirect_to part_path(@part), notice: "投稿しました"
    else
      render 'new'
    end
  end

  def show
    @comments = @question.comments
    @comment = @question.comments.build
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to question_path(@question), notice: '質問を編集しました！'
    else
      render 'edit'
    end
  end

  def destroy
    @question.destroy
    redirect_to questions_path, notice: '質問を削除しました！'
  end

  # def user_question
  #   @search = Question.joins({:part => {:subject => :project}}).ransack(params[:q])
  #   @questions = @search.result.order(created_at: :desc)
  # end

  private

  def set_part
    @part = Part.find(params[:part_id])
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :content, :part_id, :user_id)
  end
end
