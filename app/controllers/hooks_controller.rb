class HooksController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :verify_payload unless Rails.env.test? # Too much PITA right now

  def perform
    return render json: "no pr given" unless pull_request

    if pull_request.state == "closed"
      closed
    elsif params[:hook][:action] == "opened"
      opened
    end

    render json: true
  end

  private

  def project
    @project ||= Project.find(params[:project_id])
  end

  def repository
    @repository ||= Repository.find(params[:repository_id])
  end

  def user
    project.users.first
  end

  def pull_request
    @pull_request ||= if params[:pull_request]
      Git::PullRequest.from_api_response(params[:pull_request], repository: repository, client: GithubClient.new(project))
    end
  end

  def closed
    NoteSync.new(project, pull_request).call
  end

  def opened
    message = <<-eos.gsub /^\s+/, ""
      Howdy from Release Ninja! When your pull request is ready, do one of the following:

      * [Notify Release Team](#{create_reviews_url(pull_request_id: pull_request.number, project_id: project.id, repository_id: repository.id)})
      * Don't notify anyone because it's a small change or doesn't concern them

      Whatever you do though, make sure you :tada:
    eos
    GithubClient.new(project).add_comment(repository.full_name, pull_request.number, message)
  end

  def verify_payload
    payload_body = request.body.read
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), project.secret_token, payload_body)
    render text: "Signatures didn't match!", status: :unprocessable_entity unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
  end
end