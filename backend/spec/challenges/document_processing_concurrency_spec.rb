require "rails_helper"

RSpec.describe "document processing concurrency" do
  self.use_transactional_tests = false

  include TableCleaner

  before { clear_flowops_tables }
  after { clear_flowops_tables }

  it "performs one extraction when two workers claim the same document together" do
    document = create(:document, filename: "invoice-77.pdf", status: "pending", extracted_data: nil)
    JobStartBarrier.barrier = ThreadBarrier.new(2)
    errors = Queue.new

    threads = Array.new(2) do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          DocumentProcessingJob.new.perform(document.id)
        end
      rescue StandardError => error
        errors << error
      end
    end

    threads.each { |thread| thread.join(5) }
    lingering = threads.select(&:alive?)
    lingering.each(&:kill)
    expect(lingering).to be_empty
    expect(errors.size).to eq(0)

    document.reload
    expect(document.status).to eq("processed")
    expect(document.extracted_data).to include("invoice_number" => "INV-77")
    expect(ExtractionRun.where(document: document).count).to eq(1)
  ensure
    JobStartBarrier.barrier = nil
  end
end

module JobStartBarrier
  def already_processed?(document)
    JobStartBarrier.barrier&.arrive
    super
  end

  class << self
    attr_accessor :barrier
  end
end

unless DocumentProcessingJob.ancestors.include?(JobStartBarrier)
  DocumentProcessingJob.prepend(JobStartBarrier)
end
