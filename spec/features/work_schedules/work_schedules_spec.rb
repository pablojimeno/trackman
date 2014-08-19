require "spec_helper"
include Warden::Test::Helpers
Warden.test_mode!

describe "device management" do

    before (:each) do
      @user = FactoryGirl.create(:manager) 
      login_as @user, scope: :user
      @user
    end

  it "should allow to create new device" do 
    visit new_work_schedule_path
    page.status_code.should be 200
    # page.should have_css('#device_name')

    # fill_in "device_name", :with => "device1"
    # fill_in "device_emei", :with => "testemei"
    # fill_in "device_name", :with => "device1"
    # click_button "Save"

    # Device.where(emei: "testemei").should exist

    # page.should have_content("Device was successfully created")

  end

  it "should allow to destroy a device" do 
    visit work_schedules_path
    page.status_code.should be 200
    #page.should have_content('Sign out')
  end

  it "should allow to list all devices" do 
    visit work_schedules_path
    page.status_code.should be 200
    # page.should have_content('Sign out')
  end




end