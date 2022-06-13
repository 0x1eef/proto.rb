require_relative "setup"

RSpec.describe "Ryo objects" do
  let(:car) { Ryo(name: "Car") }

  describe "#respond_to?" do
    context "when a property is defined" do
      subject { car.respond_to?(:name) }
      it { is_expected.to be(true) }
    end

    context "when a property is not defined" do
      subject { car.respond_to?(:foobar) }
      it { is_expected.to be(true) }
    end
  end

  describe "#method_missing" do
    context "when a property doesn't exist" do
      subject { car.foobar }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#eql?" do
    context "when two objects are equal" do
      let(:car_2) { Ryo(name: "Car") }
      subject { car == car_2 }
      it { is_expected.to be(true) }
    end

    context "when an object and a Hash are equal" do
      subject { car == {'name' => 'Car'} }
      it { is_expected.to be(true) }
    end

    context "when an object is compared against nil" do
      subject { car == nil }
      it { is_expected.to be(false) }
    end
  end

  describe "when a property overshadows a method" do
    let(:car) do
      Ryo(tap: "property")
    end

    context "when a block is not given" do
      subject { car.tap }
      it { is_expected.to eq("property") }
    end

    context "when a block is given" do
      subject { car.tap {} }
      it { is_expected.to eq(car) }
    end
  end
end