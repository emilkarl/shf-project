RSpec.shared_context 'create logger' do

  SPEC_LOGDIR_PREFIX = 'alspec' unless defined? SPEC_LOGDIR_PREFIX
  SPEC_LOGNAME       = 'testlog.log' unless defined? SPEC_LOGNAME

  let(:logfilepath) { File.join(Dir.mktmpdir(SPEC_LOGDIR_PREFIX), SPEC_LOGNAME) }
  let(:log) { ActivityLogger.open(logfilepath, 'TEST', 'open', false) }
end
