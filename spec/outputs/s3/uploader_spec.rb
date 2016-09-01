# Encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/s3/uploader"
require "logstash/outputs/s3/temporary_file"
require "aws-sdk"

describe LogStash::Outputs::S3::Uploader do
  let(:max_upload_workers) { 1 }
  let(:bucket_name) { "foobar-bucket" }
  let(:client) { Aws::S3::Client.new(stub_responses: true) }
  let(:bucket) { Aws::S3::Bucket.new(bucket_name, :client => client) }
  let(:temporary_directory) { Stud::Temporary.directory }
  let(:upload_options) { {} }

  let(:file) do
    f = LogStash::Outputs::S3::TemporaryFile.new(temporary_directory, "foobar")
    f.write("random content")
    f
  end

  subject { described_class.new(bucket, max_upload_workers, upload_options) }

  it "expect to change the thread name" do
    expect(LogStash::Util).to receive(:set_thread_name).with(/S3 output uploader/)
    subject.upload_async(file)
  end
    
  it "upload file to the s3 bucket" do
    subject.upload(file)
  end

  it "execute a callback when the upload is complete" do
    callback = proc { |f| }
    expect(callback).to receive(:call).with(file)
    subject.upload(file, :on_complete => callback)
  end
end
