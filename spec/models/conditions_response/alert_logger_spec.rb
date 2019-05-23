require 'rails_helper'

require 'shared_context/activity_logger'


RSpec.describe AlertLogger do

  include_context 'create logger'


  let(:alert) { MembershipExpireAlert.instance }
  let(:subject) { described_class.new(log, alert) }


  describe '.log_success' do

    it 'calls log_msg_start and gets the alert class name' do

      expect(alert).to receive(:success_str).with('this is a').and_return('success!')

      expect(subject).to receive(:msg_start).and_call_original

      subject.log_success('this is a')
      expect(File.read(logfilepath)).to include("[info] MembershipExpireAlert")
    end


    it 'sends the success_method to the alert with the log_args to get the string and writes it to the log' do

      expect(alert).to receive(:success_str).with('this is a').and_return('success!')

      subject.log_success('this is a')
      expect(File.read(logfilepath)).to include("[info] MembershipExpireAlert email sent success!")
    end


    it 'can specify a custom success method to call' do

      # define a method for MemberMailer just for this test
      MembershipExpireAlert.class_eval do
        def custom_success_str_method(args)
          "Detta är #{args}!"
        end
      end

      alert_logger_custom_str = described_class.new(log, alert, success_info_method: :custom_success_str_method)

      expect(alert).to receive(:custom_success_str_method).with('framgångsrikt').and_call_original

      alert_logger_custom_str.log_success('framgångsrikt')
      expect(File.read(logfilepath)).to include("[info] MembershipExpireAlert email sent Detta är framgångsrikt!")

      # remove the method we added
      MembershipExpireAlert.undef_method(:custom_success_str_method)
    end


    describe 'handles a variable number of arguments (other than error:)' do

      it 'two args' do

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_success_str_method(arg1, arg2)
            "Detta är #{arg1} and #{arg2}!"
          end
        end

        alert_logger_custom_str = described_class.new(log, alert, success_info_method: :custom_success_str_method)

        expect(alert).to receive(:custom_success_str_method).with('really', 'big').and_call_original

        alert_logger_custom_str.log_success('really', 'big')
        expect(File.read(logfilepath)).to include("[info] MembershipExpireAlert email sent Detta är really and big!.")

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_success_str_method)
      end


      it 'five args' do

        five_args = [1,2,3,4,5]

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_success_str_method(*args)
            "Detta är #{args.join(', ')}"
          end
        end

        alert_logger_custom_str = described_class.new(log, alert, success_info_method: :custom_success_str_method)

        expect(alert).to receive(:custom_success_str_method).with(five_args).and_call_original

        alert_logger_custom_str.log_success(five_args)
        expect(File.read(logfilepath)).to include("[info] MembershipExpireAlert email sent Detta är 1, 2, 3, 4, 5.")

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_success_str_method)
      end

    end

  end


  describe '.log_failure' do

    it 'calls log_msg_start and gets the alert class name' do

      expect(alert).to receive(:failure_str).with('this is a').and_return('big FAIL!')

      expect(subject).to receive(:msg_start).and_call_original

      subject.log_failure('this is a', error: Net::ProtocolError)

      expect(File.read(logfilepath)).to include("[error] MembershipExpireAlert")
    end


    it 'sends the failure_method to the alert with the log_args to get the string to write to the log' do

      expect(alert).to receive(:failure_str).with('this is a').and_return('big FAIL!')

      subject.log_failure('this is a')
      expect(File.read(logfilepath)).to include("[error] MembershipExpireAlert email ATTEMPT FAILED big FAIL!.")
    end


    it 'includes error info if any error is given' do

      expect(alert).to receive(:failure_str).with('this is a').and_return('big FAIL!')

      subject.log_failure('this is a', error: Net::ProtocolError)
      expect(File.read(logfilepath)).to include("[error] MembershipExpireAlert email ATTEMPT FAILED big FAIL!. #{Net::ProtocolError}")
    end


    it "says 'Also see for possible info' with the Mailer log" do

      expect(alert).to receive(:failure_str).with('this is a').and_return('big FAIL!')

      subject.log_failure('this is a', error: Net::ProtocolError)

      expect(File.read(logfilepath)).to include("Also see for possible info #{ApplicationMailer::LOG_FILE}")
    end


    it 'calls log_msg_start and gets the alert class name' do

      expect(alert).to receive(:failure_str).with('this is a').and_return('big FAIL!')

      expect(subject).to receive(:msg_start)

      subject.log_failure('this is a', error: Net::ProtocolError)

    end


    it 'can specify a custom method to call for the failure info callback' do

      # define a method for MemberMailer just for this test
      MembershipExpireAlert.class_eval do
        def custom_failure_str_method(args)
          "Detta är ett stort #{args}"
        end
      end

      alert_logger_custom_str = described_class.new(log, alert, failure_info_method: :custom_failure_str_method)

      expect(alert).to receive(:custom_failure_str_method).with('misslyckande').and_call_original

      alert_logger_custom_str.log_failure('misslyckande')
      expect(File.read(logfilepath)).to include("[error] MembershipExpireAlert email ATTEMPT FAILED Detta är ett stort misslyckande.")

      # remove the method we added
      MembershipExpireAlert.undef_method(:custom_failure_str_method)
    end


    describe 'handles a variable number of arguments (other than error:)' do

      it 'two args' do

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_failure_str_method(arg1, arg2)
            "Detta är #{arg1} and #{arg2}!"
          end
        end

        alert_logger_custom_str = described_class.new(log, alert, failure_info_method: :custom_failure_str_method)

        expect(alert).to receive(:custom_failure_str_method).with('really', 'big').and_call_original

        alert_logger_custom_str.log_failure('really', 'big', error: Net::ProtocolError)
        expect(File.read(logfilepath)).to include("[error] MembershipExpireAlert email ATTEMPT FAILED Detta är really and big!.")

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_failure_str_method)
      end


      it 'five args ([1,2,3,4,5]) and error: ' do

        five_args = [1,2,3,4,5]

        # define a method for MembershipExpireAlert just for this test
        MembershipExpireAlert.class_eval do
          def custom_failure_str_method(*args)
            "Detta är #{args.join(', ')}"
          end
        end

        alert_logger_custom_str = described_class.new(log, alert, failure_info_method: :custom_failure_str_method)

        expect(alert).to receive(:custom_failure_str_method).with(five_args).and_call_original

        alert_logger_custom_str.log_failure(five_args, error: Net::ProtocolError)
        expect(File.read(logfilepath)).to include("[error] MembershipExpireAlert email ATTEMPT FAILED Detta är 1, 2, 3, 4, 5.")

        # remove the method we added
        MembershipExpireAlert.undef_method(:custom_failure_str_method)
      end

    end

  end

end
