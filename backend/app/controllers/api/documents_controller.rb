module Api
  class DocumentsController < BaseController
    def show
      document = current_account.documents.find(params[:id])
      render json: DocumentSerializer.new(document).as_json
    end

    def enqueue
      document = current_account.documents.find(params[:id])
      DocumentProcessingJob.perform_async(document.id) unless document.status == "processed"
      render json: DocumentSerializer.new(document).as_json, status: :accepted
    end
  end
end
