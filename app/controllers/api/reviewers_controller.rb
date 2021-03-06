class Api::ReviewersController < Api::BaseController
  def index
    respond_with :api, project, reviewers
  end

  def show
    respond_with :api, project, reviewer
  end

  def create
    new_reviewer = Reviewer.where(email: reviewer_params[:email]).first_or_create!
    new_reviewer.projects << project
    respond_with :api, project, new_reviewer
  end

  def destroy
    respond_with :api, project, reviewers.delete(reviewer)
  end

  private

  def projects
    @projects ||= current_team.projects
  end

  def project
    @project ||= projects.find(params[:project_id])
  end

  def reviewers
    project.reviewers
  end

  def reviewer
    reviewers.find(params[:id])
  end

  def reviewer_params
    params.permit(:email)
  end
end
