require 'spec_helper'

describe Email do
  describe ".from" do
    it "should return a string for the from email address" do
      email = Email.create!(:from_address => EmailAddress.create!(address: "matthew@foo.com"))
      email.from.should == "matthew@foo.com"
    end

    it "should allow the from_address to be set by a string" do
      email = Email.create!(:from => "matthew@foo.com")
      email.from.should == "matthew@foo.com"
    end
  end

  describe ".from_address" do
    it "should return an EmailAddress object" do
      email = Email.create!(from: "matthew@foo.org")
      a1 = EmailAddress.find_by_address("matthew@foo.org")
      a1.should_not be_nil
      email.from_address.should == a1
    end
  end

  describe ".to" do
    it "should return an array for all the email addresses" do
      Email.create!(:to => ["mlandauer@foo.org", "matthew@bar.com"])

      email = Email.find_by_to("mlandauer@foo.org, matthew@bar.com")
      email.to.should == ["mlandauer@foo.org", "matthew@bar.com"]
    end
  end

  describe ".to_addresses" do
    it "should return an array of EmailAddress objects" do
      email = Email.create!(to: ["mlandauer@foo.org", "matthew@bar.com"])
      a1 = EmailAddress.find_by_address("mlandauer@foo.org")
      a2 = EmailAddress.find_by_address("matthew@bar.com")
      a1.should_not be_nil
      a2.should_not be_nil
      email.to_addresses.should == [a1, a2]
    end
  end
end