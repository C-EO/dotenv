require "spec_helper"

describe Dotenv::Environment do
  subject { env("OPTION_A=1\nOPTION_B=2") }

  describe "initialize" do
    it "reads the file" do
      expect(subject["OPTION_A"]).to eq("1")
      expect(subject["OPTION_B"]).to eq("2")
    end

    it "fails if file does not exist" do
      expect do
        Dotenv::Environment.new(".does_not_exists")
      end.to raise_error(Errno::ENOENT)
    end
  end

  describe "apply" do
    it "sets variables in ENV" do
      subject.apply
      expect(ENV["OPTION_A"]).to eq("1")
    end

    it "does not overwrite defined variables" do
      ENV["OPTION_A"] = "predefined"
      subject.apply
      expect(ENV["OPTION_A"]).to eq("predefined")
    end

    context "with overwrite: true" do
      subject { env("OPTION_A=1\nOPTION_B=2", overwrite: true) }

      it "sets variables in the ENV" do
        subject.apply
        expect(ENV["OPTION_A"]).to eq("1")
      end

      it "overwrites defined variables" do
        ENV["OPTION_A"] = "predefined"
        subject.apply
        expect(ENV["OPTION_A"]).to eq("1")
      end
    end
  end

  require "tempfile"
  def env(text, ...)
    file = Tempfile.new("dotenv")
    file.write text
    file.close
    env = Dotenv::Environment.new(file.path, ...)
    file.unlink
    env
  end
end
