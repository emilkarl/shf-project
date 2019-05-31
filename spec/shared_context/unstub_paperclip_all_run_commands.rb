# 'unstub' (call the original) all Paperclip 'run' commands.

RSpec.shared_context 'unstub Paperclip all run commands' do

  before(:each) do
    allow(Paperclip).to receive(:run).with( any_args).and_call_original
  end

end
