# frozen_string_literal: true

RSpec.describe Teneo::Logger do
  before do
    class TestLogger
      include Teneo::Logger
    end

    @tl = TestLogger.new
  end

  it "perform standard logging operations" do
    expect(@tl.debug "message").to output(/^D, \[.*\] DEBUG : message/).to_stdout
    # tl.warn "message"
    # tl.error "huge error: [%d] %s", 1000, "Exit"
    # tl.info "Running application: %s", t.class.name
  end
end
