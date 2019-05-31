# Stub the most expensive Paperclip methods
#
# This stubs the system calls that Paperclip does to post-process an attachment --
#   like create other styles of it (thumbnails, etc)
#
# This does _not_ stub calls 'file' to check the MIME type or to link or delete the attachment file.


STUB_CODE_FILEPATH = File.join(__dir__, 'stub_paperclip_methods_code.rb') unless defined?(STUB_CODE_FILEPATH)


RSpec.shared_context 'stub Paperclip methods' do

  source = STUB_CODE_FILEPATH

  code_to_stub_methods = ''
  File.open(source, 'r') do | f |
    code_to_stub_methods <<   f.read
  end

  before(:each) { eval(code_to_stub_methods)  }

end
