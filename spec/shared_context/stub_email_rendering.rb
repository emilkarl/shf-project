# Stub rendering emails. This saves a lot of time becuase it means that
# emails will not be written to logs.


RSpec.shared_context 'stub email rendering' do

  before(:each) do

    mock_html_part = begin
      Mail::Part.new do
        content_type "text/html"
        body 'HTML version of the email would be rendered here (stubbed)'
      end
    end
    allow_any_instance_of(Premailer::Rails::Hook).to receive(:generate_html_part)
                                                         .and_return(mock_html_part)
    allow_any_instance_of(ActionView::Renderer).to receive(:render).and_return('View is rendered here (stubbed).')

  end

end
