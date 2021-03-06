require "spec_helper"
include Warden::Test::Helpers
Warden.test_mode!

describe DeviceModel do

  include_context "sign_in"
  include_context "sign_out"

  before (:each) do
    device_model = FactoryGirl.create(:device_model)
  end

  it "should allow to create new device model" do     
    visit new_device_model_path
    page.status_code.should be 200
    # page.should have_css('#device_model_name')

    # fill_in "device_model_name", :with => "NewDeviceModel"
    # click_button "Save"

    # DeviceModel.where(name: "NewDeviceModel").should exist
    # page.should have_content("Device model was successfully created")
  end

  skip "should allow to destroy a device model" do 
    visit device_models_path
    page.status_code.should be 200
    # expect { click_link 'Destroy' }.to change(DeviceModel, :count).by(-1)
  end

  it "should allow to list all device models" do 
    visit device_models_path
    page.status_code.should be 200
    # page.should have_content('NewDeviceModel')
  end

  it "should allow to edit a device model" do 
    visit edit_device_model_path(DeviceModel.first)
    page.status_code.should be 200
    # page.should have_css('#device_model_name')

    # fill_in "device_model_name", :with => "NewDeviceModel2"
    # click_button "Save"

    # DeviceModel.where(name: "NewDeviceModel").should_not exist
    # DeviceModel.where(name: "NewDeviceModel2").should exist
  end

end