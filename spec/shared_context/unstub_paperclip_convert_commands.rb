# 'unstub' (call the original) Paperclip 'convert' commands. This is often
# used to ge the MIME type of an attachment

RSpec.shared_context 'unstub Paperclip convert commands' do

  before(:each) do
    allow(Paperclip).to receive(:run).with('convert', any_args).and_call_original
  end

end
