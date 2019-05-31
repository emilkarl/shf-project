# 'unstub' (call the original) Paperclip 'identify' commands. This is often
# used to get file characteristics

RSpec.shared_context 'unstub Paperclip identify commands' do

  before(:each) do
    allow(Paperclip).to receive(:run).with('identify', any_args).and_call_original
  end

end
