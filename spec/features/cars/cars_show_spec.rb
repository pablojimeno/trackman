require "spec_helper"
include Warden::Test::Helpers
Warden.test_mode!

describe Car do

  include_context "sign_in"
  include_context "sign_out"

  before (:each) do
    Time.zone = "GMT" 
  end

  it "should allow to create new car" do
    car = FactoryGirl.create(:car)
    device = FactoryGirl.create(:device, car_id: car.id)
    traccar_device = Traccar::Device.create(name: device.name, uniqueId: device.emei)
    traccar_device.users << Traccar::User.first
    positions = device.traccar_device.positions

    first_day = Time.zone.parse(Chronic.parse('4 dec 8:00 am').to_s)
    5.times do |i| 
      positions << Traccar::Position.create( 
        latitude: 48.856614, 
        longitude: 2.352222, 
        speed: 60.0, 
        time: first_day, 
        created_at: first_day, 
        valid: true, 
        device_id: traccar_device.id)
      # move time by 15 minutes
      first_day += 900 #900 seconds = 15 minutes
    end 


    next_day = Time.zone.parse(Chronic.parse('5 dec 8:00 am').to_s)
    # inject next_day positions 
    5.times do |i|
      positions << Traccar::Position.create( 
        latitude: 48.856614, 
        longitude: 2.352222, 
        speed: 60.0, 
        time: next_day, 
        created_at: next_day, 
        valid: true, 
        device_id: device.traccar_device.id)
      # move time by 15 minutes
      next_day += 900 #900 seconds = 15 minutes
    end 
    
    visit car_path(car) 

    # select first day positions with filter        
    fill_in "dates_start_date", with: "4/12/2014"
    fill_in "dates_start_time", with: "06:00"
    fill_in "dates_end_date", with: "4/12/2014"
    fill_in "dates_end_time", with: "07:00"
    click_button "Apply"
    expect(page).to have_content("No positions available for this period")

    fill_in "dates_start_date", with: "4/12/2014"
    fill_in "dates_start_time", with: "08:15"
    fill_in "dates_end_date", with: "4/12/2014"
    fill_in "dates_end_time", with: "09:00"
    click_button "Apply"
    expect(page).to_not have_content("No positions available for this period")
    
    page.should have_content("was successfully created")
  end






end