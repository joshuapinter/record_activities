require File.expand_path("spec_helper", File.dirname(__FILE__))

describe :record_activities do
  before do
    Activity.delete_all
    Comment.delete_all
    User.stamper = User.create!
  end
  describe "basics" do
    it "records an activity when a record is created" do
      lambda{Comment.create!(:text=>'x')}.should change(Activity,:count).by(+1)
    end
    it "does not record an activity when a record fails to e created" do
      lambda{Comment.create}.should change(Activity,:count).by(0)
    end
  end
  describe "storing" do
    before do
      Comment.create!(:text=>'x')
    end
    it "records with current stamper as actor" do
      Activity.first.actor.id.should == User.stamper
    end
    it "records the action being performed" do
      Comment.first.save!
      Activity.last.action.should == 'update'
    end
    it "records the subject as the item being changed" do
      Activity.first.subject.should == Comment.first
    end
  end
  describe "recording custom activities" do
    it "does not store default activities" do
      lambda{Comment2.create!(:text=>'x')}.should_not change(Activity,:count)
    end
    it "stores custom activities" do
      c = Comment2.create!(:text=>'x')
      lambda{c.record_activity_foo}.should change(Activity,:count).by(+1)
    end
    it "stores custom actions" do
      c = Comment2.create!(:text=>'x')
      c.record_activity_foo
      Activity.first.action.should == 'foo'
    end
  end
end