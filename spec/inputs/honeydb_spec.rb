# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/honeydb"

describe LogStash::Inputs::honeydb do

  it_behaves_like "an interruptible input plugin" do
    let(:config) { { "interval" => 300 } }
  end

end
