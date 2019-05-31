# These lines should be read in and passed to a block that can use them
# This file is the 'raw' code so that it can be used both by RSpec _and_
# Cucumber features.  Otherwise this code would have to be duplicated
# in order to stub these methods in both the RSpec tests and Cucumber features.
#

allow_any_instance_of(Paperclip::Processor).to receive(:convert)
allow_any_instance_of(Paperclip::Processor).to receive(:identify)
allow_any_instance_of(Paperclip::Attachment).to receive(:post_process_file)

# stub calls to run commands
allow(Paperclip).to receive(:run)
                        .with('convert', any_args)
                        .and_return(true)

allow(Paperclip).to receive(:run)
                        .with('identify', any_args)
                        .and_return("100x100")

allow(Paperclip).to receive(:run)
                        .with('file', any_args)
                        .and_return("image/png; charset=binary")
