# frozen_string_literal: true

require_relative "logger/version"

require "logging"

require "dry-configurable"

module Teneo

  # This module adds logging functionality to any class.
  #
  # Just include the Teneo::Logger module and the methods debug, info, warn, error and fatal will be
  # available to the class instance. Each method takes a message argument and optional extra parameters.
  #
  # It is possible to overwrite the {#logger} method with your own implementation to use
  # a different logger for your class.
  #
  # The methods all call the {#message} method with the logging level as first argument
  # and the supplied arguments appended.
  #
  # Example:
  #
  #     require 'teneo/logger'
  #     class TestLogger
  #       include Teneo::Logger
  #     end
  #     tl = TestLogger.new
  #     tl.debug 'message'
  #     tl.warn 'message'
  #     tl.error 'huge error: [%d] %s', 1000, 'Exit'
  #     tl.info 'Running application: %s', t.class.name
  #
  # produces:
  #     D, [...] DEBUG : message
  #     W, [...]  WARN : message
  #     E, [...] ERROR : huge error: [1000] Exit
  #     I, [...]  INFO : Running application TestLogger
  #

  module Logger

    # Logger Configuration

    extend Dry::Configurable

    setting :log_layout, default: {
                           pattern: "%.1l, [%d #%p.%t] %5l%m\n",
                           date_pattern: "%Y-%m-%dT%H:%M:%S.%L",
                         }
    setting :log_formatter, default: -> {
                             ::Logging::Layouts::Pattern.new(Teneo::Logger.config.log_layout)
                            }
    setting :application, default: nil
    setting :subject, default: nil

    def set_application(name = nil)
      return if name.nil? or !name.is_a?(String) or name.strip.empty?
      Teneo::Logger.config.application = " -- #{name}"
    end

    def set_subject(name = nil)
      return if name.nil? or !name.is_a?(String) or name.strip.empty?
      Teneo::Logger.config.subject = " - #{name}"
    end

    # Get the logger instance
    #
    # Default implementation is to get the root logger from the Config, but can be overwritten for sub-loggers.
    # @!method(logger)
    def logger(name = nil, appenders = nil)
      name ||= "root"
      logger = ::Logging.logger[name]
      if logger.appenders.empty?
        logger.appenders = appenders || ::Logging.appenders.stdout(layout: Teneo::Logger.config.log_formatter)
      end
      logger
    end

    # Send a debug message to the logger.
    #
    # If the optional extra parameters are supplied, the first parameter will be interpreted as a format
    # specification. It's up to the caller to make sure the format specification complies with the number and
    # types of the extra arguments. If the format substitution fails, the message will be printed as:
    # '<msg> - [<args>]'.
    #
    # @param [String] msg the message.
    # @param [Array] args optional extra arguments.
    # @param [String] application the application name
    # @param [String] subject the subject name
    def debug(msg, *args, application: nil, subject: nil)
      self.message *args, message: msg, severity: :DEBUG, application: application, subject: subject
    end

    # Send an info message to the logger.
    #
    # (see #debug)
    # @param (see #debug)
    def info(msg, *args, application: nil, subject: nil)
      self.message *args, message: msg, severity: :INFO, application: application, subject: subject
    end

    # Send a warning message to the logger.
    #
    # (see #debug)
    # @param (see #debug)
    def warn(msg, *args, application: nil, subject: nil)
      self.message *args, message: msg, severity: :WARN, application: application, subject: subject
    end

    # Send an error message to the logger.
    #
    # (see #debug)
    # @param (see #debug)
    def error(msg, *args, application: nil, subject: nil)
      self.message *args, message: msg, severity: :ERROR, application: application, subject: subject
    end

    # Send a fatal message to the logger.
    #
    # (see #debug)
    # @param (see #debug)
    def fatal_error(msg, *args, application: nil, subject: nil)
      self.message *args, message: msg, severity: :FATAL, application: application, subject: subject
    end

    # The method that performs the code logging action.
    #
    # If extra arguments are supplied, the message string is expected to be a format specification string and the
    # extra arguments will be applied to it.
    #
    # If the :application argument is not supplied or nil, the Teneo::Logger.config.application string will be used.
    # If that string is still nil, the class name is used.
    #
    # @param [String] message message string
    # @param [{::Logger::Severity}] severity
    # @param [String] application the application name
    # @param [String] subject the subject name
    # @param [Object] args optional list of extra arguments
    def message(*args, message:, severity: :INFO, application: nil, subject: nil)
      application ||= Teneo::Logger.config.application || self.class.name
      subject ||= Teneo::Logger.config.subject
      message_text = "#{application}#{subject} : #{(msg % args rescue "#{msg}#{args.empty? ? "" : " - #{args}"}")}"
      self.logger.add(::Logging.level_num(severity), message_text)
    end
  end
end
