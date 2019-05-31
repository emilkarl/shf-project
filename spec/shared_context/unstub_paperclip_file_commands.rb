# 'unstub' (call the original) Paperclip 'file' commands. This is often
# used to ge the MIME type of an attachment

RSpec.shared_context 'unstub Paperclip file commands' do

  before(:each) do
    allow(Paperclip).to receive(:run).with('file', any_args).and_call_original
  end

end
